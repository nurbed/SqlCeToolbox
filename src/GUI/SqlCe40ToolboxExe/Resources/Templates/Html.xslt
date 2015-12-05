﻿<?xml version="1.0" encoding="utf-8"?>
<!-- XSL Template for converting the XML documentation to HTML -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl">
    <xsl:output
        method="html"
        indent="yes"
        omit-xml-declaration="yes"
        media-type="text/html"
        doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
        encoding="utf-8" />

    <xsl:template match="/">
        <html>
            <head>
                <title>
                    <xsl:value-of select="concat(/database/@name, ' Database Schema')" />
                </title>
                <meta http-equiv="content-type" content="text/html; charset=utf-8" />
                <style type="text/css">
                    body { background-color: #fff; color: #000; font-family: Consolas, monospace}
                    a:link { color: #03d; }
                    a:visited { color: #039; }
                    a:hover { color: #09f; }
                    table { border-collapse: collapse; width: 100%; }
                    table caption { color: #666; text-align: right; font-size: 65%; margin-bottom: .5ex; }
                    table td, table th { border: solid 1px #666; border-collapse: collapse; padding: .3ex .5ex; vertical-align: top; }
                    table tbody tr:hover { background-color: #ffc; }
                    table thead th { text-align: left; background-color: #ccc; }
                    table tbody th { text-align: left; white-space: nowrap; }
                    .table { page-break-inside: avoid; }
                    .pk { float: right; cursor: arrow; color: #999; }
                    .type { white-space: nowrap; }
                    .null { text-align: center; }
                    .flag { white-space: nowrap; font-size: 70%; display: inline-block; border: solid 1px #ccc; padding: .25ex .5ex; background-color: #ddd; margin-right: 1ex; }
                    .tocref { float: right; text-decoration: none; font-weight: normal; }
                    .footer { text-align: center; margin-top: 1em; font-size: 80%;}
                    li.view:before { content: "VIEW"; font-size: 70%; display: inline-block; border: solid 1px #ccc; padding: .25ex .5ex; background-color: #ddd; margin-right: 1ex; }
                    @media print {
                    body { font-size: .8em; }
                    #toc, .tocref { display: none; }
                    a:link, a:visited { color: #000; text-decoration: none; }
                    }
                </style>
            </head>
            <body>
                <h1>
                    <xsl:value-of select="concat(/database/@name, ' Database Schema')" />
                </h1>
                <!-- Table of contents -->
                <xsl:call-template name="TableOfContents"/>
                
                <!-- Process all database properties -->
                <xsl:call-template name="DbPropertyTable" />
              
                <!-- Process all schemas -->
                <xsl:for-each select="/database/schema">
                    <xsl:sort select="@name"/>
                    <xsl:variable name="SchemaName" select="@name" />
                    <!-- Process tables in schema -->
                    <xsl:for-each select="/database/object[@type='USER_TABLE']">
                        <xsl:sort select="@name"/>
                        <xsl:call-template name="SingleDbTableOrView" />
                    </xsl:for-each>

                </xsl:for-each>
                <!-- Footer -->
                <div class="footer">
                    Generated by <a href="http://SqlDbDoc.codeplex.com/">DB&gt;doc</a> and <a href="http://sqlcetoolbox.codeplex.com/">SQL Server Compact Toolbox</a> on
                    <xsl:value-of select="msxsl:format-date(/database/@dateGenerated, 'MMMM dd, yyyy', 'en-US')"/>
                    <xsl:value-of select="msxsl:format-time(/database/@dateGenerated, ', HH:mm:ss', 'en-US')"/>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="TableOfContents">
        <div id="toc">
            <ul>
                <xsl:for-each select="/database/object[@type='USER_TABLE']">
                    <xsl:sort select="@name"/>
                    <li class="table">
                        <a href="#{@id}">
                            <xsl:value-of select="@name"/>
                        </a>
                    </li>
                </xsl:for-each>

            </ul>
        </div>
    </xsl:template>

    <xsl:template name="SingleDbTableOrView">
        <div class="table">
            <h2 id="{@id}">
                <a href="#toc" class="tocref">&#8679;</a>
                <xsl:choose>
                    <xsl:when test="@type='USER_TABLE'">Table </xsl:when>
                    <xsl:when test="@type='VIEW'">View </xsl:when>
                </xsl:choose>
                <xsl:value-of select="@name"/>
            </h2>

            <xsl:if test="@description">
                <p>
                    <xsl:value-of select="@description"/>
                </p>
            </xsl:if>

            <table>
                <thead>
                    <tr>
                        <th style="width:30ex">Name</th>
                        <th style="width:20ex">Type</th>
                        <th style="width:4ex">NULL</th>
                        <th>Comment</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="column">
                        <tr>
                            <th>
                                <xsl:if test="primaryKey">
                                    <xsl:variable name="PK" select="primaryKey" />
                                    <span class="pk" title="PRIMARY KEY {//object[@id=$PK/@refId]/@name}">&#9670;</span>
                                </xsl:if>
                                <xsl:value-of select="@name"/>
                            </th>
                            <td class="type">
                                <xsl:value-of select="@type"/>
                                <xsl:choose>
                                    <xsl:when test="@length=-1"> (max)</xsl:when>
                                    <xsl:when test="@type='char' or @type='varchar' or @type='binary' or @type='varbinary' or @type='nchar' or @type='nvarchar'">
                                        <xsl:value-of select="concat(' (', @length, ')')"/>
                                    </xsl:when>
                                    <xsl:when test="@type='real' or @type='money' or @type='float' or @type='decimal' or @type='numeric' or @type='smallmoney'">
                                        <xsl:value-of select="concat(' (', @precision, ', ', @scale, ')')"/>
                                    </xsl:when>
                                </xsl:choose>
                            </td>
                            <td class="null">
                                <xsl:choose>
                                    <xsl:when test="@nullable='true'">&#9746;</xsl:when>
                                    <xsl:otherwise>&#9744;</xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <xsl:if test="@identity='true'">
                                    <span class="flag">IDENTITY <xsl:value-of select="@identitySeed"/></span>
                                </xsl:if>
                                <xsl:if test="@computed='true'">
                                    <span class="flag">COMPUTED</span>
                                </xsl:if>
                                <xsl:if test="@rowguidcol='true'">
                                    <span class="flag">ROWGUIDCOL</span>
                                </xsl:if>
                                <xsl:if test="default">
                                    <span class="flag">
                                        <xsl:value-of select="concat('DEFAULT ', default/@value)"/>
                                    </span>
                                </xsl:if>
                                <xsl:if test="foreignKey">
                                    <xsl:variable name="FK" select="foreignKey" />
                                    <span class="flag" title="{//object[@id=$FK/@refId]/@name}">
                                        <xsl:text>&#8680; </xsl:text>
                                        <a href="#{$FK/@tableId}">
                                            <xsl:value-of select="concat('', //object[@id=$FK/@tableId]/@name)"/>
                                        </a>
                                        <xsl:value-of select="concat('.', foreignKey/@column)"/>
                                    </span>
                                </xsl:if>
                                <xsl:value-of select="@description"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:template>


  <xsl:template name="DbPropertyTable">
    <div class="table">
      <h2 id="{@key}">
        <a href="#toc" class="tocref">&#8679;</a>
        Database Properties
      </h2>

      <table>
        <thead>
          <tr>
            <th>Property</th>
            <th>Value</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="/database/dbProperty">
            <tr>
              <td class="type">
                <xsl:value-of select="@key"/>
              </td>
              <td class="type">
                <xsl:value-of select="@value"/>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>


</xsl:stylesheet>