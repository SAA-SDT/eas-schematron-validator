<?xml version="1.0" encoding="UTF-8"?>
<pattern id="codes-validation" xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:key name="iso639-1-key" match="context[@name='iso639-1']" use="value"/>
    <xsl:key name="iso639-2b-key" match="context[@name='iso639-2b']" use="value"/>
    <xsl:key name="iso639-2t-key" match="context[@name='iso639-2t']" use="value"/>
    <xsl:key name="iso639-3-key" match="context[@name='iso639-3']" use="value"/>
    <xsl:key name="iso15924-key" match="context[@name='iso15924']" use="value"/>
    
    <!-- Note:  iso3166-1 is the usual use case.  iso3166-2 is a speciality use case for country subdivisions, and iso3166-3 is a speciality use case for expired/superseded country codes, such as BUR -->
    <!-- Since we do not have an available list for -2 and -3, those will both be handled by regex -->
    <xsl:key name="iso3166-alpha2-key" match="context[@name='iso3166']/codes[@type='alpha-2']" use="value"/>
    <xsl:key name="iso3166-alpha3-key" match="context[@name='iso3166']/codes[@type='alpha-3']" use="value"/>
    <xsl:key name="iso3166-numeric-key" match="context[@name='iso3166']/codes[@type='numeric']" use="value"/>
    
    <xsl:key name="bcp47-lang-key" match="context[@name='bcp47']/subtags[@type='language']" use="value"/>
    <xsl:key name="bcp47-region-key" match="context[@name='bcp47']/subtags[@type='region']" use="value"/>
    <xsl:key name="bcp47-script-key" match="context[@name='bcp47']/subtags[@type='script']" use="value"/>
    <xsl:key name="bcp47-variant-key" match="context[@name='bcp47']/subtags[@type='variant']" use="value"/>
    
    <xsl:key name="xhtml-element-key"  match="context[@name='xhtml-matrix']/xhtml-elements/element" use="@name" />
    <xsl:key name="global-xhtml-attr-key" match="context[@name='xhtml-matrix']/global-attributes/attribute" use="@name" />
    <xsl:key name="element-xhtml-attr-key" match="context[@name='xhtml-matrix']/xhtml-elements/element/attribute" use="concat(parent::element/@name, '|', @name)" />
    <!--
    Composite Key: 
        Here, we concatenate the list name and value (e.g., 'publicationStatus|approved') to prevent identical values in different lists from colliding and causing false positive validations.
        Will need to udpate, at least for "status", since that attribute will have different valid values per its context... so, parentElement|attribue|value ???
    -->
    <xsl:key name="eas-bp-key" match="context[@name='eas-best-practices']/list/value" use="concat(../@name, '|', .)"/>
    
    <let name="current-country-encoding" value="(*/*:control/@countryEncoding)"/>
    <let name="language-encoding" value="(*/*:control/@languageEncoding)"/>
    <let name="ISIL-regex" value="'^(([A-Z]{2})|([a-zA-Z]{1})|([a-zA-Z]{3,4}))(-[a-zA-Z0-9:/-]{1,11})$'"/>
    
    <!-- 
        TO DO:

        * write tests for all this stuff!!
    -->
    
    <let name="check-agentType" value="if (*/*:control/@agentTypeEncoding eq 'EASList') then true() else false()"/>
    <let name="check-audience" value="if (*/*:control/@audienceEncoding eq 'EASList') then true() else false()"/>
    <let name="check-country-codes" value="if ($current-country-encoding eq 'otherCountryEncoding') then false() else true()"/>
    <let name="check-date-attributes" value="if (/*/*:control/@dateEncoding eq 'otherDateEncoding') then false() else true()"/>
    <let name="check-detailLevel" value="if (*/*:control/@detailLevelEncoding eq 'otherDetailLevelEncoding') then false() else true()"/>
    <let name="check-language-codes" value="if ($language-encoding eq 'otherLanguageEncoding') then false() else true()"/>
    <let name="check-maintenanceEventType" value="if (*/*:control/@maintenanceEventTypeEncoding eq 'EASList') then true() else false()"/>
    <let name="check-maintenanceStatus" value="if (*/*:control/@maintenanceStatusEncoding eq 'EASList') then true() else false()"/>
    <let name="check-publicationStatus" value="if (*/*:control/@publicationStatusEncoding eq 'EASList') then true() else false()"/>
    <let name="check-referredEntityType" value="if (*/*:control/@referredEntityTypeEncoding eq 'EASList') then true() else false()"/>
    <let name="check-relationType" value="if (*/*:control/@relationTypeEncoding eq 'EASList') then true() else false()"/>
    <let name="check-repository-codes" value="if (*/*:control/@repositoryEncoding eq 'otherRepositoryEncoding') then false() else true()"/>
    <let name="check-script-codes" value="if (*/*:control/@scriptEncoding eq 'otherScriptEncoding') then false() else true()"/>
    <let name="check-status" value="if (*/*:control/@statusEncoding eq 'EASList') then true() else false()"/>
    <let name="check-targetType" value="if (*/*:control/@targetTypeEncoding eq 'EASList') then true() else false()"/>
 
    <rule context="*:agencyCode[$check-repository-codes]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="matches($val, $ISIL-regex)">
            The agency code '<value-of select="$val"/>' does not follow the ISO 15511 (ISIL) format.
        </assert>
    </rule>
    
    <rule context="*:agent/@agentType[$check-agentType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('agentType', '|', $val), $registry))">
            Agent type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="@audience[$check-audience]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('audience', '|', $val), $registry))">
            Audience value of '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="*:control/@detailStatus[$check-detailLevel]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('detailLevel', '|', $val), $registry))">
            Detail level '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="*:control/@maintenanceStatus[$check-maintenanceStatus]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('maintenanceStatus', '|', $val), $registry))">
            Maintenance status '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="*:control/@publicationStatus[$check-publicationStatus]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('publicationStatus', '|', $val), $registry))">
            Publication status '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="@countryCode[$check-country-codes][$current-country-encoding eq 'iso3166-1-alpha-2']">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('iso3166-alpha2-key', $val, $registry))">
            The code '<value-of select="$val"/>' is not a recognized ISO 3166-1 Alpha 2 country code.
        </assert>
    </rule>
    <rule context="@countryCode[$check-country-codes][$current-country-encoding eq 'iso3166-1-alpha-3']">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('iso3166-alpha3-key', $val, $registry))">
            The code '<value-of select="$val"/>' is not a recognized ISO 3166-1 Alpha 3 country code.
        </assert>
    </rule>
    <rule context="@countryCode[$check-country-codes][$current-country-encoding eq 'iso3166-1-numeric']">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('iso3166-numeric-key', $val, $registry))">
            The code '<value-of select="$val"/>' is not a recognized ISO 3166-1 Numeric country code.
        </assert>
    </rule>
    <rule context="@countryCode[$check-country-codes][$current-country-encoding eq 'iso3166-2']">
        <let name="val" value="normalize-space(.)"/>
        <assert test="matches(., '^[A-Z]{2}-[A-Z0-9]{1,3}$') and exists(key('iso3166-alpha2-key', substring-before(., '-'), $registry))">
            The code '<value-of select="$val"/>' is not a recognized ISO 3166-2 country and subdivision code.
        </assert>
    </rule>
    <rule context="@countryCode[$check-country-codes][$current-country-encoding eq 'iso3166-3']">
        <let name="val" value="normalize-space(.)"/>
        <assert test="matches($val, '^[A-Z]{1,3}$')">
            The code '<value-of select="$val"/>' does not match the expected regular expression pattern for an ISO 3166-3 expired country code.
        </assert>
    </rule>
    
    <rule context="*:formattingExtension//*">
        <let name="el-name" value="local-name()"/>
        <assert test="$ns = ('http://www.w3.org/1999/xhtml', 'http://www.w3.org/1998/Math/MathML', 'http://www.w3.org/2000/svg')">
            The element &lt;<name/>&gt; must be in the XHTML, MathML, or SVG namespace.
        </assert>
        <assert test="$ns != 'http://www.w3.org/1999/xhtml' or exists(key('xhtml-element-key', $el-name, $registry))">
            The XHTML element '&lt;<value-of select="$el-name"/>&gt;' is not permitted within formattingExtension.
        </assert>
    </rule>
    
    <rule context="(@languageCode | @languageOfElement)[$check-language-codes][$language-encoding eq 'iso639-1']">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('iso639-1-key', $val, $registry))">
            The code '<value-of select="$val"/>' is not valid for ISO 639-1.
        </assert>
    </rule>

    <rule context="(@languageCode | @languageOfElement)[$check-language-codes][$language-encoding eq 'iso639-2']">
        <let name="val" value="normalize-space(.)"/>
        <assert test="matches($val, '^q[a-t][a-z]$') or exists(key('iso639-2b-key', $val, $registry)) or exists(key('iso639-2t-key', $val, $registry))">
            The code '<value-of select="$val"/>' is not valid for generic ISO 639-2.
        </assert>
    </rule>

    <rule context="(@languageCode | @languageOfElement)[$check-language-codes][$language-encoding eq 'iso639-2b']">
        <let name="val" value="normalize-space(.)"/>
        <assert test="matches($val, '^q[a-t][a-z]$') or exists(key('iso639-2b-key', $val, $registry))">
            The code '<value-of select="$val"/>' is not a valid Bibliographic ISO 639-2b code.
        </assert>
    </rule>

    <rule context="(@languageCode | @languageOfElement)[$check-language-codes][$language-encoding eq 'iso639-2t']">
        <let name="val" value="normalize-space(.)"/>
        <assert test="matches($val, '^q[a-t][a-z]$') or exists(key('iso639-2t-key', $val, $registry))">
            The code '<value-of select="$val"/>' is not a valid Terminologic ISO 639-2t code.
        </assert>
    </rule>

    <rule context="(@languageCode | @languageOfElement)[$check-language-codes][$language-encoding eq 'iso639-3']">
        <let name="val" value="normalize-space(.)"/>
        <assert test="matches($val, '^q[a-t][a-z]$') or exists(key('iso639-3-key', $val, $registry))">
            The code '<value-of select="$val"/>' is not valid for ISO 639-3.
        </assert>
    </rule>

    <rule context="(@languageCode | @languageOfElement)[$check-language-codes][$language-encoding eq 'ietf-bcp-47']">
        <let name="val" value="normalize-space(.)"/>
        <let name="tokens" value="tokenize($val, '-')"/>
        <let name="primary" value="$tokens[1]"/>
        <let name="invalid-subtags" value="$tokens[position() > 1][not(
            matches(., '^Qaa[a-z]$|^Qab[a-x]$', 'i') or
            matches(., '^Q[M-Z]$|^X[A-Z]$', 'i') or
            exists(key('bcp47-script-key', ., $registry)) or 
            exists(key('bcp47-region-key', ., $registry)) or
            exists(key('bcp47-variant-key', ., $registry))
            )]"/>
        
        <assert test="matches($val, '^[a-zA-Z]{2,8}(-[a-zA-Z]{4})?(-([a-zA-Z]{2}|[0-9]{3}))?(-([a-zA-Z0-9]{5,8}|[0-9][a-zA-Z0-9]{3}))?$', 'i')">
            The BCP 47 tag '<value-of select="$val"/>' is structurally invalid. It must follow the order: Language-Script-Region-Variant.
        </assert>
        
        <assert test="matches($primary, '^q[a-t][a-z]$', 'i') or exists(key('bcp47-lang-key', $primary, $registry))">
            The primary language subtag '<value-of select="$primary"/>' is not a valid BCP 47 language.
        </assert>
        
        <report test="count($invalid-subtags) gt 0">
            The following subtag(s) are not recognized BCP 47 scripts, regions, or variants: '<value-of select="string-join($invalid-subtags, '; ')"/>'.
        </report>
    </rule>
      
    <rule context="*:maintenanceEvent/@maintenanceEventType[$check-maintenanceEventType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('maintenanceEventType', '|', $val), $registry))">
            Maintenance Event type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="*:referringString/@referredEntityType[$check-referredEntityType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('referredEntityType', '|', $val), $registry))">
            Referred Entity type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="(*:agent|*:relation)/@relationType[$check-relationType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('relationType', '|', $val), $registry))">
            Relation type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="(@scriptCode | @scriptOfElement)[$check-script-codes]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('iso15924-key', $val, $registry))">
            The script code '<value-of select="$val"/>' is not a valid ISO 15924 code.
        </assert>
    </rule>
    
    <!-- NOTE:  this will need to be updated, later, to separate the date status values from the rest.
    Right now, all four valid status values get grouped together. -->
    <!-- FIXME:  https://github.com/SAA-SDT/EAS-Best-Practices/issues/21 -->
    <rule context="@status[$check-status]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('status', '|', $val), $registry))">
            Status value of '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
    
    <rule context="*:relation/@targetType[$check-targetType]">
        <let name="val" value="normalize-space(.)"/>
        <assert test="exists(key('eas-bp-key', concat('targetType', '|', $val), $registry))">
            Target type '<value-of select="$val"/>' is not a valid EASList value.
        </assert>
    </rule>
           
</pattern>