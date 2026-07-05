<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:eas="http://archivists.org/eas/functions"
    exclude-result-prefixes="xs eas"
    version="3.0">
    
    <xsl:function name="eas:is-valid-edtf" as="xs:boolean">
        <xsl:param name="dateString" as="xs:string?"/>
        <xsl:variable name="qualifier" select="'[~%?]?'"/>
        <xsl:variable name="months" select="'(0[1-9]|1[0-2])'"/>
        <xsl:variable name="seasons" select="'(2[1-4]|2[5-9]|3[0-9]|4[0-1])'"/>
        <xsl:variable name="Y" select="'[+-]?(([0-9X])([0-9X]{3})|([1-9X])([0-9X]{4,9}))'"/>
        <xsl:variable name="M" select="concat('(', $months, '|([0-1]X)|X[0-9]|XX)')"/>
        <xsl:variable name="M_S" select="concat('(', $M, '|', $seasons)"/>
        <xsl:variable name="D" select="'(([0X][1-9X])|([012X][0-9X])|([3X][0-1X]))'"/>
        <xsl:variable name="T" select="'[T| ](0[0-9]|1[0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9]|60)(?:Z|[+-](?:2[0-3]|[01][0-9]):[0-5][0-9])$'"/>
        <xsl:variable name="iso8601-regex" select="concat( 
            '^', $qualifier, $Y, $qualifier, '$', '|', 
            '^', $qualifier, $Y, $qualifier, '-', $qualifier, $M_S, $qualifier, '$', '|', 
            '^', $qualifier, $Y, $qualifier, '-', $qualifier, $M, $qualifier, '-', $qualifier, $D, $qualifier, '$', '|', 
            '^', $qualifier, $Y, $qualifier, '-', $qualifier, $M, $qualifier, '-', $qualifier, $D, $qualifier, $T, '$' 
            )"/>
        <xsl:sequence select="if (normalize-space($dateString)) then matches(normalize-space($dateString), $iso8601-regex) else false()"/>
    </xsl:function>
    
    <xsl:function name="eas:is-after" as="xs:boolean">
        <xsl:param name="start" as="xs:string"/>
        <xsl:param name="end" as="xs:string"/>
        
        <xsl:variable name="strippedStart" select="replace($start, '[~%?]', '')"/>
        <xsl:variable name="strippedEnd" select="replace($end, '[~%?]', '')"/>
        
        <xsl:variable name="cleanStart" select="
            if (starts-with($strippedStart, '-')) 
            then replace($strippedStart, 'X', '9') 
            else replace($strippedStart, 'X', '0')
            "/>
        
        <xsl:variable name="cleanEnd" select="
            if (starts-with($strippedEnd, '-')) 
            then replace($strippedEnd, 'X', '0') 
            else replace($strippedEnd, 'X', '9')
            "/>
        
        <xsl:variable name="padStart" select="
            if (matches($cleanStart, '^-?\d{4}$')) then concat($cleanStart, '-01-01') 
            else if (matches($cleanStart, '^-?\d{4}-\d{2}$')) then concat($cleanStart, '-01') 
            else $cleanStart
            "/>
        
        <xsl:variable name="padEnd" select="
            if (matches($cleanEnd, '^-?\d{4}$')) then concat($cleanEnd, '-12-31') 
            else if (matches($cleanEnd, '^-?\d{4}-\d{2}$')) then concat($cleanEnd, '-31') 
            else $cleanEnd
            "/>
        
        <xsl:sequence select="
            if ($padStart castable as xs:date and $padEnd castable as xs:date) 
            then xs:date($padStart) > xs:date($padEnd) 
            else $padStart gt $padEnd
            "/>
    </xsl:function>
    
    <xsl:function name="eas:is-calendar-valid" as="xs:boolean">
        <xsl:param name="date" as="xs:string"/>
        <xsl:variable name="clean" select="translate($date, '?~%', '')"/>
        <xsl:choose>
            <xsl:when test="matches($clean, '^[0-9]{4}-[0-9]{2}-[0-9]{2}(T.*)?$')">
                <xsl:variable name="y" select="xs:integer(substring($clean, 1, 4))"/>
                <xsl:variable name="m" select="xs:integer(substring($clean, 6, 2))"/>
                <xsl:variable name="d" select="xs:integer(substring($clean, 9, 2))"/>
                <xsl:choose>
                    <xsl:when test="$m &lt; 1 or $m &gt; 12"><xsl:sequence select="false()"/></xsl:when>
                    <xsl:when test="$m = (1, 3, 5, 7, 8, 10, 12) and $d &gt; 31"><xsl:sequence select="false()"/></xsl:when>
                    <xsl:when test="$m = (4, 6, 9, 11) and $d &gt; 30"><xsl:sequence select="false()"/></xsl:when>
                    <xsl:when test="$m = 2">
                        <xsl:variable name="is_leap" select="eas:is-leap-year($clean)"/>
                        <xsl:choose>
                            <xsl:when test="$is_leap and $d &gt; 29"><xsl:sequence select="false()"/></xsl:when>
                            <xsl:when test="not($is_leap) and $d &gt; 28"><xsl:sequence select="false()"/></xsl:when>
                            <xsl:otherwise><xsl:sequence select="true()"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise><xsl:sequence select="true()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:sequence select="true()"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="eas:is-leap-year" as="xs:boolean">
        <xsl:param name="dateString" as="xs:string?"/>
        <xsl:variable name="year-string" select="replace(replace($dateString, '[+%~?]', ''), '^((-?\d+)).*$', '$1')"/>
        <xsl:variable name="year" select="if ($year-string castable as xs:integer) then xs:integer($year-string) else 0"/>
        <xsl:sequence select="if ($year = 0) then false() else ($year mod 4 = 0 and $year mod 100 != 0) or ($year mod 400 = 0)"/>
    </xsl:function>
   
</xsl:stylesheet>