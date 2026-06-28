<?xml version="1.0" encoding="UTF-8"?>
<pattern id="eac-ead-codes-validation" xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <let name="check-addressLine" value="if (*/*:control/@addressLineTypeEncoding eq 'EASList') then true() else false()"/>
    <let name="check-contactLine" value="if (*/*:control/@contactLineTypeEncoding eq 'EASList') then true() else false()"/>
    <let name="check-placeType" value="if (*/*:control/@placeTypeEncoding eq 'EASList') then true() else false()"/>
    
    <rule context="*:addressLine/@addressLineType[$check-addressLine]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('addressLineType', '|', $val), $registry))">
            Address Line type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="*:contactLine/@contactLineType[$check-contactLine]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('contactLineType', '|', $val), $registry))">
            Contact Line type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="*:function/@relationType[$check-relationType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('relationType', '|', $val), $registry))">
            Relation type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="*:function/@targetType[$check-targetType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('targetType', '|', $val), $registry))">
            Target type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="*:place/@placeType[$check-placeType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('placeType', '|', $val), $registry))">
            Place type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="*:place/@relationType[$check-relationType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('relationType', '|', $val), $registry))">
            Relation type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="*:place/@targetType[$check-targetType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('targetType', '|', $val), $registry))">
            Target type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
</pattern>
    
    

