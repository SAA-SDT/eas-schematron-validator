<?xml version="1.0" encoding="UTF-8"?>
<pattern id="date-range" xmlns="http://purl.oclc.org/dsdl/schematron">
    <rule context="*:dateRange[$check-date-attributes][*:fromDate and *:toDate]">
        <let name="from_startValue" value="(*:fromDate/@standardDate, *:fromDate/@notBefore)[1]"/>     
        <let name="to_endValue" value="(*:toDate/@standardDate, *:toDate/@notAfter)[1]"/>
        
        <assert test="not($from_startValue and $to_endValue) or not(eas:is-after($from_startValue, $to_endValue))">
            The fromDate element (<value-of select="$from_startValue"/>) must not occur chronologically after its corresponding toDate element (<value-of select="$to_endValue"/>) within the dateRange.
        </assert>
    </rule>
</pattern>