<?xml version="1.0" encoding="UTF-8"?>
<pattern id="date-formats" xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:eas="http://archivists.org/eas/functions">
    <rule context="*:eventDateTime[not(@standardDateTime)]">
        <assert test="normalize-space(.)">The eventDateTime element requires either a standardDateTime attribute or text.</assert>
    </rule>
    <rule context="*[@era]">
        <assert test="@era = ('ce', 'bce')">Suggested values for the era attribute are 'ce' or 'bce'.</assert>
    </rule>
    <rule context="(*:date | *:fromDate | *:toDate)[$check-date-attributes][@notBefore | @notAfter | @standardDate]">
        <assert test="every $d in (@notBefore, @notAfter, @standardDate[not(matches(., '\.\.|/'))]) satisfies (eas:is-valid-edtf($d) and eas:is-calendar-valid($d))">
            The notBefore, notAfter, and standardDate attributes must match the TS-EAS subprofile of valid ISO 8601 dates and be valid calendar dates.
        </assert>
        
        <assert test="every $d in (tokenize(@standardDate, '(\.\.)|(/)')[normalize-space()]) satisfies (eas:is-valid-edtf($d) and eas:is-calendar-valid($d))">
            All standardDate attributes in a valid date range must match the TS-EAS subprofile of valid ISO 8601 dates and be valid calendar dates.
        </assert>
        
        <report test="count(tokenize(@standardDate, '(\.\.)|(/)')) &gt;= 3">
            This date expression has too many range operators. Only a single "/" or ".." is permitted.
        </report>
    </rule>
</pattern>