<?xml version="1.0" encoding="UTF-8"?>
<pattern id="eac-eaf-codes-validation" xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <let name="check-identityType" value="if (*/*:control/@identityTypeEncoding eq 'EASList') then true() else false()"/>
    
    <rule context="*:identity/@identityType[$check-identityType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('identityType', '|', $val), $registry))">
            Identity type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
</pattern>