<?xml version="1.0" encoding="UTF-8"?>
<pattern id="unique-ids" xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <!-- NOTE: this standalone pattern depends upon the 'key-any-id' key, which is defined in the '/src/modules/shared/reference-attributes.sch' file -->
    
    <!-- NOTE:  this could easily confict with embedded XHTML IDs, but that should likely be called out as an error -->
    <rule context="*[@id]"> 
        <assert test="count(key('key-any-id', @id)) = 1">
            This element does not have a unique value for its 'id' attribute. The ID '<value-of select="@id"/>' is already in use.
        </assert>
    </rule>
</pattern>