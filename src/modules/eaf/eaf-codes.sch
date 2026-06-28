<?xml version="1.0" encoding="UTF-8"?>
<pattern id="eaf-codes-validation" xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <let name="check-functionStatus" value="if (eaf:eaf/eaf:control/@functionStatusEncoding eq 'EASList') then true() else false()"/>

    <rule context="eaf:control/@functionStatus[$check-functionStatus]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('functionStatus', '|', $val), $registry))">
            Function status '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
</pattern>