<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    version="3.0">
    
    <!-- value is switched to 'sef' for NPM pipeline  -->
    <xsl:param name="build-target" select="'publish'"/>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="sch:schema">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:comment expand-text="true">
This schematron file has been generated automatically, and was last updated at: 

{current-dateTime()}
                        
If you would like to contribute to this project, please see: 
https://github.com/SAA-SDT/TS-EAS-subteam-notes/wiki/Contributing-to-the-EAS-standards
                        
Comments, questions, and suggestions may be addressed to: 
ts-eas@archivists.org
            </xsl:comment>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xsl:include">
        <xsl:variable name="included-doc" select="doc(resolve-uri(@href, base-uri(.)))"/>
        <xsl:copy-of select="$included-doc/*:stylesheet/node() | $included-doc/*:transform/node()"/>
    </xsl:template>
    
    <xsl:template match="sch:include">
        <xsl:apply-templates select="doc(resolve-uri(@href, base-uri(.)))//xsl:key" mode="copy-key"/>
        <xsl:apply-templates select="doc(resolve-uri(@href, base-uri(.)))/node()"/>
    </xsl:template>
    
    <xsl:template match="xsl:key|comment()"/>
    
    <xsl:template match="xsl:key" mode="copy-key">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="sch:let[@name='registry']">
        <xsl:choose>
            <xsl:when test="$build-target = 'sef'">
                <xsl:copy>
                    <xsl:apply-templates select="@name"/>
                    <xsl:attribute name="value">
                        <xsl:text>document('eas-registry.xml')</xsl:text>
                    </xsl:attribute>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="variable" namespace="http://www.w3.org/1999/XSL/Transform">
                    <xsl:attribute name="name" select="@name"/>
                    <xsl:copy-of select="document('../web/eas-registry.xml')/*"/>
                </xsl:element>
            </xsl:otherwise> 
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>