<?xml version="1.0" encoding="UTF-8"?>
<pattern id="tempory-patch-for-element-status-restrictions" xmlns="http://purl.oclc.org/dsdl/schematron">
    <!-- FIXME:  https://github.com/SAA-SDT/EAS-Best-Practices/issues/21 -->    
    <rule context="*:agencyCode[@status] | *:otherAgencyCode[@status] | *:nameEntry[@status]">
        <assert test="@status = ('alternative', 'authorized')">
            <name/> can only be paired with a status value of 'alternative' or 'authorized'.
        </assert>
    </rule>
    
    <rule context="*:textualDate[@status] | *:toDate[@status]">
        <assert test="@status = ('ongoing', 'unknown')">
            <name/> can only be paired with a status value of 'ongoing' or 'unknown'.
        </assert>
    </rule>
    
    <rule context="*:date[@status] | *:fromDate[@status]">
        <assert test="@status = 'unknown'">
            <name/> must have a status value of 'unknown'.
        </assert>
    </rule>
</pattern>