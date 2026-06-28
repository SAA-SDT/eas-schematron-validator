<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    queryBinding="xslt3">
    
    <ns prefix="ead" uri="https://archivists.org/ns/ead/v4"/>
    <ns prefix="eas" uri="http://archivists.org/eas/functions"/>
    <ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
    
    <!-- swith to a catalog approach, if i can it to work with NPM -->
    <include href="modules/shared/codes.sch"/>
    <include href="modules/shared/date-formats.sch"/>
    <include href="modules/shared/date-validation-patterns.sch"/>
    <include href="modules/shared/maintenance-agency.sch"/>
    <include href="modules/shared/reference-attributes.sch"/>
    <include href="modules/shared/unique-ids.sch"/>
     
    <xsl:include href="functions/date-functions.xsl"/>
    
    <!-- need to figure out the NPM build issues, but now i'm hardcoding each include rather than using a collection approach -->
    <include href="modules/eac-ead/eac-ead-codes.sch"/>
    <include href="modules/ead/ead-codes.sch"/>
    
    <let name="registry" value="document('../web/eas-registry.xml')"/>
     
</schema>
