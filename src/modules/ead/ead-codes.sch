<?xml version="1.0" encoding="UTF-8"?>
<pattern id="ead-codes-validation" xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <let name="check-coverage" value="if (ead:ead/ead:control/@coverageEncoding eq 'EASList') then true() else false()"/>
    <let name="check-dscType" value="if (ead:ead/ead:control/@descriptionOfComponentsTypeEncoding eq 'EASList') then true() else false()"/>
    <let name="check-extentType" value="if (ead:ead/ead:control/@extentTypeEncoding eq 'EASList') then true() else false()"/>
    <let name="check-formAvailableType" value="if (ead:ead/ead:control/@formAvailableTypeEncoding eq 'EASList') then true() else false()"/>
    <let name="check-functionType" value="if (ead:ead/ead:control/@functionTypeEncoding eq 'EASList') then true() else false()"/>
    <let name="check-level" value="if (ead:ead/ead:control/@levelEncoding eq 'EASList') then true() else false()"/>
    <!-- check-referredEntityType & check-targetType defined in shared/codes.sch file -->
    <!-- check-repository-code and ISIL-regex defined in shared/codes.sch file -->
    <let name="check-unitDateType" value="if (ead:ead/ead:control/@unitDateTypeEncoding eq 'EASList') then true() else false()"/>
    
    <rule context="(ead:extent|ead:formAvailable)/@coverage[$check-coverage]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('coverage', '|', $val), $registry))">
            Level '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    <rule context="ead:descriptionOfComponents/@descriptionOfComponentsTypeEncoding[$check-dscType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('descriptionOfComponentsType', '|', $val), $registry))">
            Description of Components type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    <rule context="ead:extent/@extentType[$check-extentType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('extentType', '|', $val), $registry))">
            Extent type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    <rule context="ead:formAvailable/@formAvailableType[$check-formAvailableType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('formAvailableType', '|', $val), $registry))">
            Form Available type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    <rule context="ead:function/@functionType[$check-functionType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('functionType', '|', $val), $registry))">
            Function type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    <rule context="(ead:archDesc|ead:c|ead:c01|ead:c02|ead:c03|ead:c04|ead:c05|ead:c06|ead:c07|ead:c08|ead:c09|ead:c10|ead:c11|ead:c12)/@level[$check-level]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('level', '|', $val), $registry))">
            Level '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    <rule context="ead:subject/@relationType[$check-relationType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('relationType', '|', $val), $registry))">
            Relation type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    <rule context="ead:subject/@targetType[$check-targetType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('targetType', '|', $val), $registry))">
            Target type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    <rule context="(ead:unitDate|ead:unitDateStructured)/@unitDateType[$check-unitDateType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('unitDateType', '|', $val), $registry))">
            Unit Date type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    <rule context="ead:unitId/@repositoryCode[$check-repository-codes]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="matches($val, $ISIL-regex)">
            The repository code '<value-of select="$val"/>' does not follow the ISO 15511 (ISIL) format.
        </assert>
    </rule>
</pattern>