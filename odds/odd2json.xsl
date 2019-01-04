<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:j="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:import href="../common/functions.xsl"/>
    
    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet" type="stylesheet">
        <desc>
            <p> TEI stylesheet for making JSON from ODD </p>
            <p>This software is dual-licensed:3
                
                1. Distributed under a Creative Commons Attribution-ShareAlike 3.0
                Unported License http://creativecommons.org/licenses/by-sa/3.0/ 
                
                2. http://www.opensource.org/licenses/BSD-2-Clause
                
                
                
                Redistribution and use in source and binary forms, with or without
                modification, are permitted provided that the following conditions are
                met:
                
                * Redistributions of source code must retain the above copyright
                notice, this list of conditions and the following disclaimer.
                
                * Redistributions in binary form must reproduce the above copyright
                notice, this list of conditions and the following disclaimer in the
                documentation and/or other materials provided with the distribution.
                
                This software is provided by the copyright holders and contributors
                "as is" and any express or implied warranties, including, but not
                limited to, the implied warranties of merchantability and fitness for
                a particular purpose are disclaimed. In no event shall the copyright
                holder or contributors be liable for any direct, indirect, incidental,
                special, exemplary, or consequential damages (including, but not
                limited to, procurement of substitute goods or services; loss of use,
                data, or profits; or business interruption) however caused and on any
                theory of liability, whether in contract, strict liability, or tort
                (including negligence or otherwise) arising in any way out of the use
                of this software, even if advised of the possibility of such damage.
            </p> 
            <p>Author: See AUTHORS</p>
            
            <p>Copyright: 2017, TEI Consortium</p>
        </desc>
    </doc>
    
    <xsl:output method="text"/>
    
    <xsl:param name="lang" select="'en'">
        <!-- Set this to 'all' to include documentation in all languages. -->
    </xsl:param>
    <xsl:param name="serializeDocs" select="true()"/>
    
    <xsl:template match="/">        
        <xsl:variable name="structure">
            <j:map>
                <j:string key="title">
                    <xsl:sequence select="tei:generateMetadataTitle(*)"/>
                </j:string>
                <j:string key="edition">
                    <xsl:sequence select="tei:generateEdition(*)"/>
                </j:string>
                <j:string key="generator">odd2json3</j:string>
                <j:string key="date"><xsl:sequence select="tei:whatsTheDate()"/></j:string>
                <j:array key="modules">
                    <xsl:for-each select="//tei:moduleSpec">
                        <xsl:sort select="@ident"/>
                        <j:map>
                            <j:string key="ident"><xsl:value-of select="@ident"/></j:string>
                            <j:string key="id">
                                <xsl:choose>
                                    <xsl:when test="@n">
                                        <xsl:value-of select="@n">
                                        </xsl:value-of>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="ancestor::tei:div[last()]/@xml:id"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </j:string>
                            <xsl:call-template name="desc"/>
                            <j:array key="altIdent">
                                <xsl:for-each select="tei:altIdent">
                                    <j:string><xsl:value-of select="."/></j:string>
                                </xsl:for-each>                                
                            </j:array>
                        </j:map>
                    </xsl:for-each>
                </j:array>
                <j:array key="moduleRefs">
                    <xsl:for-each select="//tei:moduleRef">
                        <xsl:sort select="@key"/>
                        <j:map>
                            <j:string key="key"><xsl:value-of select="@key"/></j:string>
                            <xsl:call-template name="desc"/>
                            <xsl:call-template name="mode"/>
                        </j:map>
                    </xsl:for-each>
                </j:array>
                <j:array key="elements">
                    <xsl:for-each select="//tei:elementSpec">
                        <xsl:sort select="@ident"/>
                        <xsl:call-template name="getMember">
                            <xsl:with-param name="attributes" select="true()" />
                        </xsl:call-template>
                    </xsl:for-each>
                </j:array>
                <j:map key="classes">
                    <j:array key="models">
                        <xsl:for-each select="//tei:classSpec[@type='model']">
                            <xsl:sort select="@ident"/>
                            <xsl:call-template name="getMember">
                                <xsl:with-param name="attributes" select="false()" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </j:array>     
                    <j:array key="attributes">
                        <xsl:for-each select="//tei:classSpec[@type='atts']">
                            <xsl:sort select="@ident"/>
                            <xsl:call-template name="getMember">
                                <xsl:with-param name="attributes" select="true()" />
                            </xsl:call-template>
                        </xsl:for-each>
                    </j:array>
                </j:map>                
                <j:array key="elementRefs">
                    <xsl:for-each select="//tei:elementRef[not(ancestor::tei:content)]">
                        <xsl:sort select="@key"/>
                        <j:map>
                            <j:string key="key">
                                <xsl:value-of select="@key"/>
                            </j:string>
                            <xsl:call-template name="desc"/>
                            <xsl:call-template name="mode"/>
                        </j:map>
                    </xsl:for-each>
                </j:array>
                <j:array key="classRefs">
                    <xsl:for-each select="//tei:classRef[not(ancestor::tei:content)]">
                        <xsl:sort select="@key"/>
                        <j:map>
                            <j:string key="key">
                                <xsl:value-of select="@key"/>
                            </j:string>
                            <xsl:call-template name="desc"/>
                            <xsl:call-template name="mode"/>
                        </j:map>
                    </xsl:for-each>
                </j:array>
                <j:array key="macros">
                    <xsl:for-each select="//tei:macroSpec[@type='pe' or not(@type)]">
                        <xsl:sort select="@ident"/>
                        <j:map>
                            <j:string key="ident">
                                <xsl:value-of select="@ident"/>
                            </j:string>
                            <j:string key="module">
                                <xsl:value-of select="@module"/>
                            </j:string>
                            <j:string key="type">
                                <xsl:value-of select="@type"/>
                            </j:string>
                            <xsl:call-template name="desc"/>
                            <xsl:call-template name="mode"/>
                        </j:map>
                    </xsl:for-each>
                </j:array>
                <j:array key="datatypes">
                    <xsl:for-each select="//tei:dataSpec">
                        <xsl:sort select="@ident"/>
                        <j:map>
                            <j:string key="ident">
                                <xsl:value-of select="@ident"/>
                            </j:string>
                            <j:string key="module">
                                <xsl:value-of select="@module"/>
                            </j:string>
                            <j:string key="type">
                                <xsl:value-of select="@type"/>
                            </j:string>
                            <xsl:call-template name="desc"/>
                            <xsl:call-template name="mode"/>
                        </j:map>
                    </xsl:for-each>
                </j:array>
                <j:array key="macroRefs">
                    <xsl:for-each select="//tei:macroRef[not(ancestor::tei:content)]">
                        <xsl:sort select="@key"/>
                        <j:map>
                            <j:string key="key">
                                <xsl:value-of select="@key"/>
                            </j:string>
                            <xsl:call-template name="desc"/>
                            <xsl:call-template name="mode"/>
                        </j:map>
                    </xsl:for-each>
                </j:array>
            </j:map>
        </xsl:variable>
        <xsl:value-of select="xml-to-json($structure, map{'indent':true()})"/>
    </xsl:template>
    
    <xsl:template name="getMember">
        <xsl:param name="attributes" select="false()"/>
        <j:map>
            <j:string key="ident"><xsl:value-of select="@ident"/></j:string>
            <xsl:variable name="nspace"
                select="(@ns,  ancestor::tei:schemaSpec[1]/@ns)[1]"/>
            <xsl:if test="$nspace">
                <j:string key="ns"><xsl:value-of select="$nspace"/></j:string>
            </xsl:if>
            <j:string key="type"><xsl:value-of select="local-name()"/></j:string>
            <j:string key="module"><xsl:value-of select="@module"/></j:string>
            <xsl:call-template name="desc"/>
            <j:array key="altIdent">
                <xsl:for-each select="tei:altIdent">
                    <j:string><xsl:value-of select="."/></j:string>
                </xsl:for-each>                                
            </j:array>
            <xsl:if test="tei:classes">
                <j:array key="classes">
                    <xsl:for-each select="tei:classes/tei:memberOf">
                        <j:map>
                            <j:string key="key"><xsl:value-of select="@key"/></j:string>
                            <j:string key="mode"><xsl:value-of select="@mode"/></j:string>
                        </j:map>
                    </xsl:for-each>
                </j:array>
            </xsl:if>
            <xsl:if test="$attributes">
                <xsl:choose>
                    <xsl:when test="self::tei:elementSpec">
                        <xsl:call-template name="attributes">
                            <xsl:with-param name="onElement" select="'true'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="attributes"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if> 
            <xsl:if test="tei:content">
                <j:array key="content">
                    <xsl:for-each select="tei:content">
                        <xsl:call-template name="getContent"/>
                    </xsl:for-each>                    
                </j:array>
            </xsl:if>
        </j:map>
    </xsl:template>
    
    <xsl:template name="getContent">
        <xsl:for-each select="*">
            <j:map>
                <xsl:choose>
                    <xsl:when test="self::tei:elementRef or self::tei:macroRef or self::tei:classRef or
                                    self::tei:dataRef">
                        <j:string key="type"><xsl:value-of select="local-name()"/></j:string>
                        <j:string key="key"><xsl:value-of select="@key"/></j:string>
                    </xsl:when>
                    <xsl:when test="self::tei:sequence or self::tei:alternate">
                        <j:string key="type"><xsl:value-of select="local-name()"/></j:string>
                        <j:string key="minOccurs"><xsl:value-of select="if (@minOccurs) then @minOccurs else 1"/></j:string>
                        <j:string key="maxOccurs"><xsl:value-of select="if (@maxOccurs) then @maxOccurs else 1"/></j:string>
                        <j:array key="content">
                            <xsl:call-template name="getContent"/>
                        </j:array>
                    </xsl:when>
                    <xsl:when test="self::tei:anyElement">
                        <j:string key="type"><xsl:value-of select="local-name()"/></j:string>
                        <j:string key="require"><xsl:value-of select="@require"/></j:string>
                        <j:string key="except"><xsl:value-of select="@except"/></j:string>
                    </xsl:when>
                    <xsl:otherwise>
                        <j:string key="type"><xsl:value-of select="local-name()"/></j:string>
                    </xsl:otherwise>
                </xsl:choose>
            </j:map>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="mode">
        <xsl:if test="@mode">
            <j:string key="key">
                <xsl:value-of select="@mode"/>
            </j:string>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="attributes">
        <xsl:param name="onElement" select="'false'"/>
        <j:array key="attributes">
            <xsl:for-each select=".//tei:attDef">
                <j:map>
                    <j:boolean key="onElement"><xsl:value-of select="$onElement"/></j:boolean>
                    <j:string key="ident">
                        <xsl:value-of select="@ident"/>
                    </j:string>
                    <j:string key="mode">
                        <xsl:value-of select="if (not(@mode)) then 'add' else @mode"/>
                    </j:string>
                    <j:string key="ns">
                        <xsl:value-of select="@ns"/>
                    </j:string>  
                    <j:string key="usage">
                        <xsl:choose>
                            <xsl:when test="@usage">
                                <xsl:value-of select="@usage"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>def</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>                        
                    </j:string>  
                    <xsl:call-template name="desc"/>
                    <j:array key="altIdent">
                        <xsl:for-each select="tei:altIdent">
                            <j:string><xsl:value-of select="."/></j:string>
                        </xsl:for-each>                                
                    </j:array>
                    <j:array key="valDesc">
                        <xsl:for-each select="tei:valDesc">
                            <xsl:choose>
                                <xsl:when test="@xml:lang and ($lang='all' or @xml:lang = $lang)">
                                    <xsl:call-template name="makeDesc"/>                  
                                </xsl:when>
                                <xsl:when test="not(@xml:lang)">
                                    <xsl:call-template name="makeDesc"/>
                                </xsl:when>
                                <xsl:otherwise/>
                            </xsl:choose>              
                        </xsl:for-each>
                    </j:array>
                    <j:map key="datatype">
                        <xsl:for-each select="tei:datatype">
                            <j:string key="min">
                                <xsl:choose>
                                    <xsl:when test="@minOccurs">
                                        <xsl:value-of select="@minOccurs"/>
                                    </xsl:when>
                                    <xsl:otherwise>1</xsl:otherwise>
                                </xsl:choose>
                            </j:string>
                            <j:string key="max">
                                <xsl:choose>
                                    <xsl:when test="@maxOccurs">
                                        <xsl:value-of select="@maxOccurs"/>
                                    </xsl:when>
                                    <xsl:otherwise>1</xsl:otherwise>
                                </xsl:choose>
                            </j:string>
                            <j:map key="dataRef">
                                <xsl:for-each select="tei:dataRef">
                                   <xsl:if test="@key">
                                       <j:string key="key"><xsl:value-of select="@key"/></j:string>
                                   </xsl:if>
                                   <xsl:if test="@name">
                                       <j:string key="name"><xsl:value-of select="@name"/></j:string>
                                   </xsl:if>
                                   <xsl:if test="@ref">
                                       <j:string key="ref"><xsl:value-of select="@ref"/></j:string>
                                   </xsl:if>
                                   <xsl:if test="@restriction">
                                       <j:string key="restriction"><xsl:value-of select="@restriction"/></j:string>
                                   </xsl:if>
                                   <j:array key="dataFacet">
                                       <xsl:for-each select="tei:dataFacet">
                                           <j:string key="name"><xsl:value-of select="@name"/></j:string>
                                           <j:string key="value"><xsl:value-of select="@value"/></j:string>
                                       </xsl:for-each>
                                   </j:array>
                                </xsl:for-each>
                            </j:map>
                        </xsl:for-each>
                    </j:map>
                    <xsl:if test="tei:valList">
                        <j:map key="valList">
                            <j:string key="type">
                                <xsl:value-of select="@type"/>
                            </j:string>
                            <j:array key="valItem">
                                <xsl:for-each select="tei:valList/tei:valItem">
                                    <j:map>
                                        <j:string key="ident">
                                            <xsl:value-of select="@ident"/>
                                        </j:string>
                                        <xsl:call-template name="desc"/>
                                        <j:array key="altIdent">
                                            <xsl:for-each select="tei:altIdent">
                                                <j:string><xsl:value-of select="."/></j:string>
                                            </xsl:for-each>                                
                                        </j:array>
                                    </j:map>                                    
                                </xsl:for-each>
                            </j:array>
                        </j:map>                                            
                    </xsl:if>
                </j:map>
            </xsl:for-each>
        </j:array>
    </xsl:template>
    
    <xsl:template name="serializeElement">
        <xsl:variable name="simplified">
            <xsl:copy-of copy-namespaces="no" select="."/>
        </xsl:variable>
        <j:string><xsl:value-of select="serialize($simplified)"/></j:string>
    </xsl:template>
    
    <xsl:template name="makeDesc">
        <xsl:choose>
            <xsl:when test="$serializeDocs">
                <xsl:call-template name="serializeElement"/>
            </xsl:when>
            <xsl:otherwise>
                <j:string><xsl:sequence select="tei:makeDescription(parent::*,false(),false())"/></j:string>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="desc">
        <j:array key="desc">
            <xsl:for-each select="tei:desc">
                <xsl:choose>
                    <xsl:when test="@xml:lang and ($lang='all' or @xml:lang = $lang)">
                        <xsl:call-template name="makeDesc"/>                  
                    </xsl:when>
                    <xsl:when test="not(@xml:lang)">
                        <xsl:call-template name="makeDesc"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>                
            </xsl:for-each>
        </j:array>
        <!-- Format the first desc into shortDesc -->
        <j:string key="shortDesc"><xsl:sequence select="tei:makeDescription(.,false(),false())"/></j:string>
        <xsl:if test="$serializeDocs">
            <j:array key="gloss">
                <xsl:for-each select="tei:gloss">
                    <xsl:choose>
                        <xsl:when test="@xml:lang and ($lang='all' or @xml:lang = $lang)">
                            <xsl:call-template name="serializeElement"/>
                        </xsl:when>
                        <xsl:when test="not(@xml:lang)">
                            <xsl:call-template name="serializeElement"/>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>                
                </xsl:for-each>
            </j:array>
        </xsl:if>        
    </xsl:template>
    
</xsl:stylesheet>