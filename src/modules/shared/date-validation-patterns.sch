<?xml version="1.0" encoding="UTF-8"?>
<pattern id="date-validation-patterns" xmlns="http://purl.oclc.org/dsdl/schematron">
    <rule context="(*:date | *:fromDate | *:toDate)[$check-date-attributes]">
        <let name="all-dates" value="for $attr in (@notAfter, @notBefore, @standardDate) return tokenize(replace($attr, '[%~?]', ''), '(\.\.)|(/)')[normalize-space()]"/>
        
        <report test="some $d in $all-dates satisfies matches($d, '-02-30|-02-31')">
            February dates cannot have a day value of 30 or 31. Check the values of your date attributes.
        </report>
        
        <report test="some $d in $all-dates satisfies (matches($d, '-02-29') and not(eas:is-leap-year($d)))">
            February 29th may only be encoded for valid leap years. One of your date attributes contains an invalid leap year.
        </report>
    </rule>
    
    <rule context="(*:date | *:fromDate | *:toDate)[$check-date-attributes][@notBefore and @notAfter]">
        <assert test="not(eas:is-after(@notBefore, @notAfter))">
            The notBefore attribute (<value-of select="@notBefore"/>) must not occur chronologically after the notAfter attribute (<value-of select="@notAfter"/>).
        </assert>
    </rule>
    
    <rule context="(*:date | *:fromDate | *:toDate)[$check-date-attributes][matches(@standardDate, '[0-9](/|\.\.)[0-9]')]">
        <let name="sep" value="if (contains(@standardDate, '..')) then '..' else '/'"/>
        <let name="begin_date" value="substring-before(@standardDate, $sep)"/>
        <let name="end_date" value="substring-after(@standardDate, $sep)"/>
        
        <assert test="not(eas:is-after($begin_date, $end_date))">
            The standardDate attribute value needs to be updated. The first date, <value-of select="$begin_date"/>, is encoded as occurring after the end date, <value-of select="$end_date"/>.
        </assert>
    </rule>
</pattern>
