<?xml version="1.0" encoding="UTF-8"?>
<pattern id="date-attribute-chronology" xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:eas="http://archivists.org/eas/functions">
    <rule context="(*:date | *:fromDate | *:toDate)[$check-date-attributes][@notBefore and @notAfter]">
        <assert test="not(eas:is-after(@notBefore, @notAfter))">
            The notBefore attribute (<value-of select="@notBefore"/>) must not occur chronologically after the notAfter attribute (<value-of select="@notAfter"/>).
        </assert>
    </rule>
    
    <rule context="(*:date | *:fromDate | *:toDate)[$check-date-attributes][matches(@standardDate, '/|\.\.')]">
        <let name="sep" value="if (contains(@standardDate, '..')) then '..' else '/'"/>
        <let name="begin_date" value="substring-before(@standardDate, $sep)"/>
        <let name="end_date" value="substring-after(@standardDate, $sep)"/>
        <assert test="not(eas:is-after($begin_date, $end_date))">
            The standardDate attribute value needs to be updated. The first date, <value-of select="$begin_date"/>, is encoded as occurring after the end date, <value-of select="$end_date"/>.
        </assert>
    </rule>
</pattern>