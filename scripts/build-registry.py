import requests
import xml.etree.ElementTree as ET
import os
import csv
import io
import re
import sys

# Set up the authenticated session once
github_session = requests.Session()
github_session.headers.update({'User-Agent': 'EAS-Registry-Builder'})

# Grab the token from the GitHub Actions environment and attach it
token = os.environ.get("GITHUB_TOKEN")
if token:
    github_session.headers.update({'Authorization': f"Bearer {token}"})

registry_config = {
    "xhtml_matrix": {
        "elements": [
            # Headings and Blocks
            "h1", "h2", "h3", "h4", "h5", "h6",
            "div", "p", "br", "hr",

            # Lists
            "ul", "ol", "li", "dl", "dt", "dd",

            # Tables
            "table", "caption", 
            "thead", "tbody", "tfoot", "tr",
            "th", "td",

            # Inline Text
            "em", "strong", "dfn", "code", 
            "sub", "sup", "span", "abbr", "cite",
            "b", "i", "small",

            # Quotes and Edits
            "blockquote", "q", "ins", "del",

            # Links and Media
            "a", "img",

            # Ruby Annotations
            "ruby", "rt", "rp"
        ]
    },
    "remote_sources": {
        "bcp47": "https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry",
        "iso639_2": "https://www.loc.gov/standards/iso639-2/ISO-639-2_utf-8.txt",
        "iso639_1": "https://id.loc.gov/vocabulary/iso639-1.rdf",
        "iso639_3": "https://iso639-3.sil.org/sites/iso639-3/files/downloads/iso-639-3.tab",
        "iso15924": "https://www.unicode.org/iso15924/iso15924.txt",
        "iso3166": "https://raw.githubusercontent.com/datasets/country-codes/master/data/country-codes.csv"
    },
    "eas_bp_api": "https://api.github.com/repos/SAA-SDT/EAS-Best-Practices/contents/docs/control/value-lists?ref=main"
}

def fetch_bcp47(url):
    try:
        response = requests.get(url, timeout=20)
        response.raise_for_status()
        subtags = {
            "language": [],
            "script": [],
            "region": [],
            "variant": []
        }
        records = response.text.split("%%")
        
        for record in records:
            entry = {}
            for line in record.strip().splitlines():
                if ":" in line:
                    k, v = line.split(":", 1)
                    entry[k.strip()] = v.strip()
            
            if "Subtag" not in entry or "Type" not in entry:
                continue
                
            # Skip all private use ranges
            # Right now, IANA formats these with '..'
            # This is brittle, so check the source file and adapt if this breaks later
            if ".." in entry["Subtag"]:
                continue
                
            if "Deprecated" not in entry:
                t = entry["Type"]
                if t in subtags: 
                    subtags[t].append(entry["Subtag"])
                
        return subtags
    
    except Exception as e:
        print(f"Error BCP47: {e}");
        sys.exit(1)
    
def fetch_iso639_1(url):
    try:
        response = requests.get(url, timeout=20)
        response.raise_for_status()
        root = ET.fromstring(response.content)
        ns = {'rdf': 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', 'skos': 'http://www.w3.org/2004/02/skos/core#'}
        codes = [notation.text for notation in root.findall('.//skos:notation', ns)]

        unique_codes = set(filter(None, codes))

        return sorted(unique_codes)

    except Exception as e:
        print(f"Error 639-1: {e}");
        sys.exit(1)
        
def fetch_iso639_2(url):
    try:
        response = requests.get(url, timeout=20)
        response.raise_for_status()
        text_data = response.content.decode('utf-8-sig')
        
        codes_b = set()
        codes_t = set()
        
        for line in text_data.splitlines():
            if not line.strip():
                continue
                
            parts = line.split('|')
            # After some trial and error, this seems to help
            code_b = parts[0].strip().lstrip('ï»¿\ufeff')
            code_t_raw = parts[1].strip() if len(parts) > 1 else ""
            
            # If the T code column is blank, inherit the B code
            code_t = code_t_raw if code_t_raw else code_b

            # Filter out the local use range, then add to respective buckets
            if code_b and code_b != 'qaa-qtz':
                codes_b.add(code_b)
            if code_t and code_t != 'qaa-qtz':
                codes_t.add(code_t)
                
        return {
            "2b": sorted(list(codes_b)),
            "2t": sorted(list(codes_t))
        }
    except Exception as e:
        print(f"Error 639-2: {e}");
        sys.exit(1)

def fetch_iso639_3(url):
    try:
        response = requests.get(url, timeout=20)
        response.raise_for_status()
        lines = response.text.strip().split('\n')
        codes = [line.split('\t')[0] for line in lines[1:]]

        unique_codes = set(filter(None, codes))

        return sorted(unique_codes)

    except Exception as e:
        print(f"Error 639-3: {e}");
        sys.exit(1)

def fetch_iso15924(url):
    try:
        response = requests.get(url, timeout=20)
        response.raise_for_status()
        lines = response.text.strip().split('\n')
        codes = [line.split(';')[0].strip() for line in lines if not line.startswith('#') and line.strip()]
        
        unique_codes = set(filter(None, codes))

        return sorted(unique_codes)

    except Exception as e:
        print(f"Error 15924: {e}");
        sys.exit(1)

def fetch_iso3166(url):
    try:
        response = github_session.get(url, timeout=20)
        response.raise_for_status()
        f = io.StringIO(response.text)
        reader = csv.DictReader(f)
        data = {
            "alpha-2": [],
            "alpha-3": [],
            "numeric": []
        }
        for row in reader:
            if row['ISO3166-1-Alpha-2']: data["alpha-2"].append(row['ISO3166-1-Alpha-2'])
            if row['ISO3166-1-Alpha-3']: data["alpha-3"].append(row['ISO3166-1-Alpha-3'])
            if row['ISO3166-1-numeric']: data["numeric"].append(row['ISO3166-1-numeric'])
        return data
    
    except Exception as e:
        print(f"Error 3166: {e}");
        sys.exit(1)
        
def fetch_eas_best_practices(api_url):
    """Fetches and parses markdown value lists from TS-EAS Best Practices repo where the ## header is the value."""
    try:
        response = github_session.get(api_url, timeout=20)
        response.raise_for_status()
        files = response.json()
        
        all_lists = {}
        
        for file_info in files:
            name = file_info['name']
            # Skip non-markdown and value-lists.md overview
            if name.endswith('.md') and name.lower() != "value-lists.md":
                list_name = name.replace('.md', '')
                raw_url = file_info['download_url']
                
                print(f"-- Parsing {name} for header values...")
                
                md_res = github_session.get(raw_url, timeout=20)
                md_res.raise_for_status()
                
                # Handle potential BOM issues and normalize line endings
                text_data = md_res.content.decode("utf-8-sig").replace('\ufeff', '')
                
                values = []
                for line in text_data.splitlines():
                    # i.e, the h2 markdown is the 'code' we want
                    if line.startswith("## "):
                        code = line.replace("##", "").strip()
                        if code:
                            values.append(code)
                
                if values:
                    all_lists[list_name] = values
                    
        return all_lists
    
    except Exception as e:
        print(f"Error fetching EAS BP: {e}")
        sys.exit(1)


def main():
    output_dir = "web"
    os.makedirs(output_dir, exist_ok=True)
    
    root = ET.Element("registry")
    stats = {}

    # 1. XHTML Matrix (Elements only)
    context = ET.SubElement(root, "context", {"name": "xhtml-matrix"})
    
    # Build elements
    elements_el = ET.SubElement(context, "xhtml-elements")
    for el_name in registry_config["xhtml_matrix"]["elements"]:
        ET.SubElement(elements_el, "element", {"name": el_name})
            
    stats["XHTML Elements"] = len(registry_config["xhtml_matrix"]["elements"])  
    

    # 2. BCP 47
    data = fetch_bcp47(registry_config["remote_sources"]["bcp47"])
    if data:
        context = ET.SubElement(root, "context", {"name": "bcp47"})
        for k, v in data.items():
            group = ET.SubElement(context, "subtags", {"type": k})
            for val in v: 
                ET.SubElement(group, "value").text = val
        stats["BCP47"] = sum(len(x) for x in data.values())


    # 3. ISO 639-1
    data = fetch_iso639_1(registry_config["remote_sources"]["iso639_1"])
    if data:
        context = ET.SubElement(root, "context", {"name": "iso639-1"})
        for val in data: ET.SubElement(context, "value").text = val
        stats["ISO639-1"] = len(data)

    # 4. ISO 639-2 (Bibliographic and Terminology)
    data = fetch_iso639_2(registry_config["remote_sources"]["iso639_2"])
    if data:
        # 639-2b (Bibliographic / English-language only)
        context_b = ET.SubElement(root, "context", {"name": "iso639-2b"})
        for val in data["2b"]: 
            ET.SubElement(context_b, "value").text = val
        
        # 639-2t (Terminology only)
        context_t = ET.SubElement(root, "context", {"name": "iso639-2t"})
        for val in data["2t"]: 
            ET.SubElement(context_t, "value").text = val
        
        stats["ISO639-2b"] = len(data["2b"])
        stats["ISO639-2t"] = len(data["2t"])


    # 5. ISO 639-3
    data = fetch_iso639_3(registry_config["remote_sources"]["iso639_3"])
    if data:
        context = ET.SubElement(root, "context", {"name": "iso639-3"})
        for val in data: 
            ET.SubElement(context, "value").text = val
        stats["ISO639-3"] = len(data)

    # 6. ISO 15924
    data = fetch_iso15924(registry_config["remote_sources"]["iso15924"])
    if data:
        context = ET.SubElement(root, "context", {"name": "iso15924"})
        for val in data: 
            ET.SubElement(context, "value").text = val
        stats["ISO15924"] = len(data)

    # 7. ISO 3166
    data = fetch_iso3166(registry_config["remote_sources"]["iso3166"])
    if data:
        context = ET.SubElement(root, "context", {"name": "iso3166"})
        for k, v in data.items():
            group = ET.SubElement(context, "codes", {"type": k})
            for val in v: ET.SubElement(group, "value").text = val
        stats["ISO3166"] = sum(len(x) for x in data.values())

    # 8. EAS Best Practices
    data = fetch_eas_best_practices(registry_config["eas_bp_api"])
    if data:
        context = ET.SubElement(root, "context", {"name": "eas-best-practices"})
        for list_name, values in data.items():
            group = ET.SubElement(context, "list", {"name": list_name})
            for val in values:
                ET.SubElement(group, "value").text = val
        stats["EAS-BP"] = sum(len(x) for x in data.values())

    # 9. Save the updated eas-registry.xml file
    output_path = os.path.join(output_dir, "eas-registry.xml")
    tree = ET.ElementTree(root)
    # going with two spaces, since it seems to be a decent default for pretty printing with ET
    ET.indent(tree, space="  ")
    tree.write(output_path, encoding="UTF-8", xml_declaration=True)
    
    # 10. Show registry stats (per input file) to the console and in the GitHub action result
    print("\n--- Build Statistics ---")
    for k, v in stats.items(): 
        print(f"{k}: {v} values")
    print(f"\nFinal registry saved to: {output_path}")

if __name__ == "__main__":
    main()