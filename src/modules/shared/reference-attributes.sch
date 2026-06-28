<?xml version="1.0" encoding="UTF-8"?>
<pattern id="reference-attributes" xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:key name="key-convention" match="*:control/*:conventionDeclaration" use="@id" />
    <xsl:key name="key-localType" match="*:control/*:localTypeDeclaration" use="@id" />
    <xsl:key name="key-maintenanceEvent" match="*:control/*:maintenanceHistory/*:maintenanceEvent" use="@id" />
    <xsl:key name="key-source" match="*:control/*:sources/*:source | *:control/*:sources/*:source/*:citedRange" use="@id" />
    <xsl:key name="key-any-id" match="*" use="@id" />
    
    <rule context="*[@conventionDeclarationReference]">
        <assert test="every $ref in tokenize(normalize-space(@conventionDeclarationReference), '\s+') satisfies (not($ref = @id) and key('key-convention', $ref))">
            When you use the conventionDeclarationReference attribute, it must be linked to a valid conventionDeclaration element and cannot reference itself.
        </assert>
    </rule>
    
    <rule context="*[@localTypeDeclarationReference]">
        <assert test="every $ref in tokenize(normalize-space(@localTypeDeclarationReference), '\s+') satisfies (not($ref = @id) and key('key-localType', $ref))">
            When you use the localTypeDeclarationReference attribute, it must be linked to a valid localTypeDeclaration element and cannot reference itself.
        </assert>
    </rule>
    
    <rule context="*[@maintenanceEventReference]">
        <assert test="every $ref in tokenize(normalize-space(@maintenanceEventReference), '\s+') satisfies (not($ref = @id) and key('key-maintenanceEvent', $ref))">
            When you use the maintenanceEventReference attribute, it must be linked to a valid maintenanceEvent element and cannot reference itself.
        </assert>
    </rule>
    
    <rule context="*[@sourceReference]">
        <assert test="every $ref in tokenize(normalize-space(@sourceReference), '\s+') satisfies (not($ref = @id) and key('key-source', $ref))">
            When you use the sourceReference attribute, it must be linked to a valid source or citedRange element and cannot reference itself.
        </assert>
    </rule>
    
    <!-- should add additional logic per 13 different targetType attributes, e.g. person vs. resource... 
        e.g. <rule context="*[@target][@targetType] ... 
            plus a new key lookup for all elements that have a target reference pointing to their ID...
        but first, we need a list of valid elements for each.
        and, further, "container" should likely also be a valid value for targetType due to relational encoding of container elements.
        FIXME: https://github.com/SAA-SDT/EAS-Best-Practices/issues/26
    -->
    <rule context="*[@target]">
        <assert test="every $target in tokenize(normalize-space(@target), '\s+') satisfies (not($target = @id) and key('key-any-id', $target))">
            When you use the target attribute, it must be linked to another element by means of the id attribute and cannot reference itself.
        </assert>
    </rule>
    
</pattern>
