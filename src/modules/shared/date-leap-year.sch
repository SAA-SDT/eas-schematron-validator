<?xml version="1.0" encoding="UTF-8"?>
<pattern id="date-leap-year-checks" xmlns="http://purl.oclc.org/dsdl/schematron">
    <rule context="(*:date | *:fromDate | *:toDate)[$check-date-attributes]">
        <let name="all-dates" value="for $attr in (@notAfter, @notBefore, @standardDate) return tokenize(replace($attr, '[%~?]', ''), '(\.\.)|(/)')[normalize-space()]"/>
        <report test="some $d in $all-dates satisfies matches($d, '-02-30|-02-31')">
            February dates cannot have a day value of 30 or 31. Check the values of your date attributes.
        </report>
        <report test="some $d in $all-dates satisfies (matches($d, '-02-29') and not(eas:is-leap-year($d)))">
            February 29th may only be encoded for valid leap years. One of your date attributes contains an invalid leap year.
        </report>
    </rule>
</pattern>