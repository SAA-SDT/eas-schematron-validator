/**
 * This file was generated with code assistance from Google Gemini, before manual review and testing. Code reviews and suggestions most welcome! 
 * Main validation function triggered when a user uploads a file.
 * @param {string} xmlString - The raw XML content of the uploaded file.
 */
async function validateXML(xmlString) {
    // 1. Grab the UI Elements by HTML ID
    const statusElement = document.getElementById("status-message");
    const resultsContainer = document.getElementById("results-container");

    // 2. Reset UI to the "Processing..." state
    if (statusElement) {
        statusElement.innerText = "Processing...";
        statusElement.style.color = "blue"; 
        statusElement.style.display = "block";
    }
    if (resultsContainer) {
        resultsContainer.innerHTML = ""; 
    }

    // 3. Check for libraries
    if (typeof SaxonJS === "undefined" || typeof xmllint === "undefined") {
        const errorMsg = "Required libraries (SaxonJS or xmllint) are missing.";
        console.error(errorMsg);
        if (statusElement) {
            statusElement.innerText = errorMsg;
            statusElement.style.color = "red";
        }
        return;
    }

    // 4. Parse the XML string to find the root element
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(xmlString, "text/xml");
    
    if (xmlDoc.querySelector("parsererror")) {
        const errorMsg = "The uploaded file is not well-formed XML.";
        console.error(errorMsg);
        if (statusElement) {
            statusElement.innerText = errorMsg;
            statusElement.style.color = "red";
        }
        return;
    }

    // 5. Map the root element to the correct SEF file AND the correct RelaxNG Schema URL (i.e., EAC, D,or F)
    const rootName = xmlDoc.documentElement.localName; 
    let rulesFile = "";
    let schemaUrl = "";

    if (rootName === "ead") {
        rulesFile = "ead-rules.sef.json";
        schemaUrl = "https://raw.githubusercontent.com/SAA-SDT/eas-schemas/refs/heads/release_2026_07/xml-schemas/ead/ead.rng";
    } else if (rootName === "eac") {
        rulesFile = "eac-rules.sef.json";
        schemaUrl = "https://raw.githubusercontent.com/SAA-SDT/eas-schemas/refs/heads/release_2026_07/xml-schemas/eac-cpf/eac.rng";
    } else if (rootName === "eaf") {
        rulesFile = "eaf-rules.sef.json";
        schemaUrl = "https://raw.githubusercontent.com/SAA-SDT/eas-schemas/refs/heads/release_2026_07/xml-schemas/eaf/eaf.rng";
    } else {
        const errorMsg = `Unsupported XML file. Root element found: <${rootName}>. Expected <ead>, <eac>, or <eaf>.`;
        console.error(errorMsg);
        if (statusElement) {
            statusElement.innerText = errorMsg;
            statusElement.style.color = "red";
        }
        return;
    }

    // 6. Fetch Schema and run base validation via xmllint, with RNG
    try {
        if (statusElement) statusElement.innerText = `Fetching RelaxNG schema for <${rootName}>...`;
        
        const schemaResponse = await fetch(schemaUrl);
        if (!schemaResponse.ok) throw new Error(`Could not fetch schema from ${schemaUrl}`);
        const schemaString = await schemaResponse.text();

        if (statusElement) statusElement.innerText = "Running RNG Validation...";
        
        const schemaValidation = xmllint.validateXML({
            xml: xmlString,
            schema: schemaString,
            format: "rng"
        });

        // If base validation fails, then display the errors and halt the process.
        if (schemaValidation.errors && schemaValidation.errors.length > 0) {
            displayRNGErrors(schemaValidation.errors);
            if (statusElement) {
                statusElement.innerText = "Validation halted: RelaxNG errors found.";
                statusElement.style.color = "red";
            }
            return; 
        }

    } catch (err) {
        console.error("RelaxNG Error:", err);
        if (statusElement) {
            statusElement.innerText = "Failed to run base validation. Check console.";
            statusElement.style.color = "red";
        }
        return;
    }

    // 7. Run Schematron Validation
    try {
        if (statusElement) {
            statusElement.innerText = `Passed RelaxNG! Running Schematron Validation...`;
            statusElement.style.color = "blue";
        }

        const result = await SaxonJS.transform({
            stylesheetLocation: rulesFile,
            sourceText: xmlString,
            destination: "serialized"
        }, "async");

        if (statusElement) {
            statusElement.innerText = `Validation complete.`;
            statusElement.style.color = "green";
        }

        displaySVRLResults(result.principalResult);

        } catch (err) {

        console.error("Saxon-JS Error:", err);

        if (err.code && err.code.includes("ValidationError")) {
            if (statusElement) {
                statusElement.innerText = "Validation complete: Business rules violated.";
                statusElement.style.color = "red";
            }

            // The SEF threw the SVRL report inside the error object. Let's try to extract it!
            if (err.value) {
                try {
                    let svrlString = "";
                    
                    // Check if Saxon passed us a native browser DocumentFragment (NodeType 11)
                    if (err.value.nodeType === 11 || err.value instanceof DocumentFragment) {
                        // Use native JS to extract the XML string
                        const tempDiv = document.createElement("div");
                        tempDiv.appendChild(err.value.cloneNode(true));
                        svrlString = tempDiv.innerHTML;
                    } else {
                        // Fallback to Saxon's internal serializer
                        svrlString = SaxonJS.serialize(err.value, { method: "xml" });
                    }

                    // Pass the successfully extracted string to your UI renderer
                    displaySVRLResults(svrlString);
                    return; 
                    
                } catch (serializationErr) {
                    console.warn("Could not extract SVRL from error object.", serializationErr);
                }
            }

            // Fallback if the SVRL cannot be extracted
            const resultsContainer = document.getElementById("results-container");
            if (resultsContainer) {
                resultsContainer.innerHTML = `
                    <h3 style='color: red;'>Schematron Validation Failed</h3>
                    <p>The document violates one or more business rules.</p>
                    <p><em>Note: The schema is compiled in 'fail-fast' mode. Check the browser console to inspect the specific error object.</em></p>
                    `;
            }
            return;
        }

        if (statusElement) {
            statusElement.innerText = "Validation failed: System error encountered. Check the browser console for details.";
            statusElement.style.color = "red";
        }
    }
}

/**
 * Custom displayRNGErrors function to display RelaxNG errors from xmllint
 */
function displayRNGErrors(errors) {
    const resultsContainer = document.getElementById("results-container");
    if (!resultsContainer) return;
    
    let htmlOutput = "<h3 style='color: red;'>RelaxNG Validation Failed</h3>";
    htmlOutput += "<p>The document contains errors and cannot be processed further:</p>"
   
    htmlOutput += "<ul>"; 
    errors.forEach(err => {
        htmlOutput += `<li style='color: red; margin-bottom: 8px;'>${err}</li>`;
    });   
    htmlOutput += "</ul>";

    resultsContainer.innerHTML = htmlOutput;
}

/**
 * Custom displaySVRLResults function to parse the SVRL output and render it in the HTML.
 */
function displaySVRLResults(svrlString) {
    const resultsContainer = document.getElementById("results-container");
    if (!resultsContainer) return;

    const parser = new DOMParser();
    const svrlDoc = parser.parseFromString(svrlString, "text/xml");
    
    const failedAsserts = svrlDoc.querySelectorAll("failed-assert");
    const successfulReports = svrlDoc.querySelectorAll("successful-report");

    let htmlOutput = "<h3>Schematron Validation Results</h3>";

    if (failedAsserts.length === 0 && successfulReports.length === 0) {
        htmlOutput += "<p style='color: green;'><strong>Success! Document is valid and passed all Schematron tests.</strong></p>";
    } else {
        htmlOutput += "<ul>";
        failedAsserts.forEach(assert => {
            const text = assert.querySelector("text").textContent;
            const location = assert.getAttribute("location");
            htmlOutput += `<li style='color: red; margin-bottom: 8px;'><strong>Error:</strong> ${text} <br><small style='color: gray; font-family: monospace;'>Location: ${location}</small></li>`;
        });
        successfulReports.forEach(report => {
            const text = report.querySelector("text").textContent;
            const location = report.getAttribute("location");
            htmlOutput += `<li style='color: orange; margin-bottom: 8px;'><strong>Warning/Info:</strong> ${text} <br><small style='color: gray; font-family: monospace;'>Location: ${location}</small></li>`;
        });
        htmlOutput += "</ul>";
    }

    resultsContainer.innerHTML = htmlOutput;
}
