<?xml version="1.0" encoding="UTF-8"?>
<pattern id="maintenance-agency" xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <rule context="*:maintenanceAgency[*:agencyCode[not(normalize-space())]] | *:maintenanceAgency[not(*:agencyCode)]">
        <assert test="*:agencyName[normalize-space()]">The maintenanceAgency element requires either an agencyCode or agencyName element that cannot be empty.</assert>
    </rule>
    <rule context="*:maintenanceAgency[*:agencyName[not(normalize-space())]] | *:maintenanceAgency[not(*:agencyName)]">
        <assert test="*:agencyCode[normalize-space()]">The maintenanceAgency element requires either an agencyCode or agencyName element that cannot be empty.</assert>
    </rule>
</pattern>