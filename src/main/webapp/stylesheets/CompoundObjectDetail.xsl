<?xml version="1.0"?> 
<xsl:stylesheet version="1.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:java="http://xml.apache.org/xslt/java"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:layout="http://maenad.itee.uq.edu.au/lore/layout.owl#"
    exclude-result-prefixes="rdf dc dcterms ore foaf xsl layout java">

	<!--xsl:key name="ordering" match="//rdf:Description[layout:next or layout:first='1' or layout:last='1']" use="@rdf:about"/>
	<xsl:key name="ordering-inverse" match="//rdf:Description[layout:first='1' or layout:next]" use="layout:next | @rdf:about"/-->
	
   
    <xsl:output method="html" indent="yes"/>
    
    
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
    	<html>
    	   <head><title>Resource Map</title></head>
    	   <link type="text/css" rel="stylesheet" href="../stylesheets/bootstrap.min.css"/>
    	   <link type="text/css" rel="stylesheet" href="../stylesheets/lorestore.css"/>
    	<body style="padding-top:40px">
    	<div class="navbar navbar-fixed-top">
            <div class="navbar-inner">
                <div class="container">
                    <a class="brand" href="../index.html"><img src="../images/lorestorelogo.png"/></a>
                </div>
            </div>
        </div>
        <div class="container">
        <div class="content">
        <xsl:apply-templates select="//rdf:Description[ore:describes]"/>
        <xsl:apply-templates select="//rdf:Description/rdf:type[@rdf:resource='http://www.openannotation.org/ns/Annotation']"/>
        </div>
        </div>
        </body></html>  
    </xsl:template>
    
    <!-- about the resource map -->
    <xsl:template match="rdf:Description[ore:describes]">
    	<xsl:variable name="about" select="@rdf:about"/>
    	<xsl:variable name="remtitle" select="//rdf:Description[@rdf:about=$about]/dc:title[1]"/>
    	<div class="page-header main-page-header">
        <h1>
        	<!--  xsl:value-of select="java:aleg.ui.StylesheetFunctions.unescapeQuot($remtitle)"/-->
        	<xsl:value-of select="$remtitle"/>
        	<xsl:if test="not($remtitle)">Untitled Resource Map</xsl:if>
        </h1>          
        </div>
        <xsl:for-each select="//rdf:Description[@rdf:about=$about]/*">
            <xsl:call-template name="displayProp"/>
        </xsl:for-each>
        <hr />
        <!--  list aggregated resources, use layout ordering if available -->
        <!--  xsl:variable name="firstResource" select="//rdf:Description[layout:first = '1']/@rdf:about"/-->
        <xsl:choose>
        	<!--  use absolute indexes -->
        	<xsl:when test="//rdf:Description[layout:orderIndex]">
        		<xsl:for-each select="//rdf:Description">
        			<xsl:sort data-type="number" select="layout:orderIndex"/>
        			<xsl:variable name="ab" select="@rdf:about"/>
        			<!--  don't display resources that aren't aggregated  -->
        			<xsl:if test="layout:orderIndex and //rdf:Description/ore:aggregates[@rdf:resource = $ab]">
        			    <a href="r{layout:orderIndex}"/>
	        			<xsl:call-template name="displayAggregatedResource">
	        				<xsl:with-param name="res" select="@rdf:about"/>
	       				</xsl:call-template>
       				</xsl:if>
        		</xsl:for-each>
        	</xsl:when>
        	<!-- Support ordering via next relationships: (not used in LORE at present)
        		if there are no cycles in layout info and 
        		each aggregated resource has ordering info,
        		apply templates recursively starting with first, and following next rels 
        		otherwise fall back to applying templates in document order -->
        	<!--  check for $firstResource first to avoid expensive checks if there is no layout ordering info -->
        	<!--xsl:when test="$firstResource and 
        		not(//rdf:Description[not(ore:describes or ore:aggregates or layout:last='1') and count(key('ordering-inverse',layout:next/@rdf:resource)) &gt; 1]) and
        		not(//rdf:Description[not(ore:describes or ore:aggregates) and count(key('ordering',@rdf:about)) = 0])">
	        	<xsl:apply-templates select="//rdf:Description[@rdf:about = $firstResource][layout:next]"/>
        	</xsl:when-->
        	<xsl:otherwise>
        		<xsl:apply-templates select="//rdf:Description/ore:aggregates"/>
        	</xsl:otherwise>
        </xsl:choose>
        
        
        <p>
        <xsl:variable name="modified" select="//rdf:Description[@rdf:about=$about]/dcterms:modified"/>
        <xsl:variable name="created" select="//rdf:Description[@rdf:about=$about]/dcterms:created"/>
        <xsl:if test="$created"><small>Created <xsl:value-of select="$created"/>. </small></xsl:if>
        <xsl:if test="$modified"><small>Last modified <xsl:value-of select="$modified"/>.</small></xsl:if>
        </p>
        <small>This content was sourced from the Resource Map identified as <xsl:value-of select="$about"/>. Use the View Source option in your browser to see the RDF/XML.</small>
        
    </xsl:template>

    <!--  match aggregated resources when there is not layout ordering -->
    <xsl:template match="rdf:Description/ore:aggregates">
    	<xsl:call-template name="displayAggregatedResource">
    		<xsl:with-param name="res" select="@rdf:resource"/>
    	</xsl:call-template>
    </xsl:template>
    
    <!--  match aggregated resources when layout ordering is present -->
    <!--xsl:template match="rdf:Description[layout:next or layout:last='1']">
    	<xsl:variable name="resid" select="@rdf:about"/>
    	<xsl:call-template name="displayAggregatedResource">
    		<xsl:with-param name="res" select="$resid"/>
    	</xsl:call-template>
    	<xsl:variable name="nextRes" select="layout:next/@rdf:resource | //rdf:Description[@rdf:about=$resid]/layout:next/@rdf:resource"/>
    	
    	<xsl:if test="not(layout:last='1') and $nextRes">
   			<xsl:apply-templates select="//rdf:Description[@rdf:about=$nextRes][layout:next or layout:last='1']"/>
		</xsl:if>
    </xsl:template-->
    
    <xsl:template name="displayAggregatedResource">
        <xsl:param name="res"/>
        <xsl:variable name="displaytitle">
            <xsl:choose>
                <xsl:when test="//rdf:Description[@rdf:about = $res]/dc:title[1]">
                    <!-- xsl:value-of select="java:aleg.ui.StylesheetFunctions.unescapeQuot(//rdf:Description[@rdf:about = $res]/dc:title)"/-->
                    <xsl:value-of select="//rdf:Description[@rdf:about = $res]/dc:title"/>
                </xsl:when>
                <xsl:otherwise>Untitled Resource  (<xsl:value-of select="$res"/>)</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>   
        <div>
        <h2>
         <xsl:choose>
            <xsl:when test="//rdf:Description[@rdf:about=$res]/layout:isPlaceholder = 1">
                <xsl:value-of select="$displaytitle"/> 
            </xsl:when>
            <xsl:when test="contains($res,'ex=FullTextView')">
                <img title="AustLit Text" src="/common/images/fulltext-icon.png"/>&#160;
                <a title="View text in new tab" target="_blank" class="url" href="{$res}">
                    <xsl:value-of select="$displaytitle"/>
                </a>
            </xsl:when>
         	<xsl:when test="//rdf:Description[@rdf:about = $res]/rdf:type/@rdf:resource='http://www.openarchives.org/ore/terms/ResourceMap'">
         		<img title="Nested Resource Map" src="../images/icons/oaioreicon-sm.png"/>&#160;
         		<a title="View in new tab" target="_blank" class="url" href="{$res}">
         			<xsl:value-of select="$displaytitle"/>
         		</a>
         	</xsl:when>
         	<xsl:when test="contains(//rdf:Description[@rdf:about=$res]/rdf:type/@rdf:resource,'nnotation')">
         		
         		<img title="Annotation" src="../images/icons/annotation.png"/>&#160;
         		<a title="View annotation in new tab" target="_blank" class="url" href="{$res}">
         			<xsl:value-of select="$displaytitle"/>
         		</a>
         	</xsl:when>
         	<xsl:otherwise>
         		<xsl:call-template name="displayIcon">
         			<xsl:with-param name="res" select="$res"/>
         		</xsl:call-template>
	         	<a title="View resource in new tab" target="_blank" class="url" href="{$res}">
	         		<xsl:value-of select="$displaytitle"/>
	         	</a>
         	</xsl:otherwise>
         </xsl:choose>
        </h2>
        </div>
        <xsl:if test="contains($res,'ex=ShowWork') or contains($res,'ex=ShowAgent')">
               
        </xsl:if>
        <p>
        <xsl:for-each select="//rdf:Description[@rdf:about = $res]/*">
        	<xsl:sort select="local-name()"/>
        	<xsl:call-template name="displayProp"/>
        </xsl:for-each>
        </p>
        <hr/>
    </xsl:template>

    <xsl:template name="displayIcon">
    	<xsl:param name="res"/>
    	<xsl:variable name="format" select="//rdf:Description[@rdf:about=$res]/dc:format"/>
    	<xsl:variable name="dtype" select="//rdf:Description[@rdf:about=$res]/dc:type/@rdf:resource"/>
    	<!--  dcmi types in dc:type have higher priority than mimetypes in dc:format -->
    	<xsl:variable name="icon">
	    	<xsl:choose>
	    	    <xsl:when test="$dtype">
	    	    <xsl:value-of select="substring-after($dtype,'http://purl.org/dc/dcmitype/')"/>
	    	    </xsl:when>
	    		<xsl:when test="contains($format,'image')">Image</xsl:when>
	    		<xsl:when test="contains($format,'video') or contains($format,'flash')">Film</xsl:when>
	    		<xsl:when test="contains($format,'audio')">Sound</xsl:when>
	    		<xsl:when test="contains($format,'pdf')">pdf</xsl:when>
	    	</xsl:choose>
    	</xsl:variable>
    	<xsl:if test="$icon != ''">
    	<img title="{$icon}" class="{$icon}icon" style='width:16px;height:16px;' src="../images/icons/blank.gif"/>&#160;
    	</xsl:if>
    </xsl:template>
    
    <xsl:template name="displayProp">
   		<xsl:if test="name() != 'lorerel:is_derived_from' and  name() != 'dc:format' and name() != 'dc:title' and name() != 'dcterms:modified' and name() != 'dcterms:created' and name()!='ore:describes' and name() !='rdf:type' and namespace-uri() != 'http://maenad.itee.uq.edu.au/lore/layout.owl#' and namespace-uri() != 'http://auselit.metadata.net/lorestore/' and namespace-uri() != 'http://auselit.metadata.net/oreextensions/'">
                <span class="prop" title="{namespace-uri()}{local-name()}">
                	<xsl:call-template name="capitalize-first">
                		<xsl:with-param name="str" select="translate(local-name(),'_',' ')"/>
                	</xsl:call-template>
                	<xsl:text>: </xsl:text>
                </span> 
                <xsl:choose>
                <!--  insert the escaped html fragment using javascript (xslt escapes the output)
                      TODO: The html fragment has been sanitized before being saved to the compound objects server, 
                      but it might be worth checking again just in case
                 -->
                	<xsl:when test="@rdf:datatype='http://maenad.itee.uq.edu.au/lore/layout.owl#escapedHTMLFragment'">
                	    <xsl:variable name="propid" select="generate-id(.)"/>
                	    <div id="{$propid}"></div>
                	    <xsl:variable name="apos">'</xsl:variable>
                		<xsl:variable name="quot">"</xsl:variable>
                		<xsl:variable name="translated" select="translate(.,$quot,$apos)"/>
                		<!--  script type="text/javascript">
                			<xsl:text>try{Ext.get('</xsl:text>
                			<xsl:value-of select="$propid"/><xsl:text>').insertHtml("beforeBegin","</xsl:text><xsl:value-of select='$translated'/>
                			<xsl:text>&lt;br/>");} catch (ex){} </xsl:text>
                		</script-->
                	</xsl:when>
                    <xsl:when test="text()">
                        
                        <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--  todo look up subject term -->
                    	<xsl:variable name="ref" select="@rdf:resource"/>
                    	<xsl:variable name="reftitle" select="//rdf:Description[@rdf:about = $ref]/dc:title"/>
                    	<xsl:variable name="reftype" select="//rdf:Description[@rdf:about = $ref]/rdf:type/@rdf:resource"/>
                    	<!--  modify link to add stylesheet for annotations or viewer for compound objects -->
                    	
                    	<xsl:choose>
                    	    <xsl:when test="$ref = 'http://auselit.metadata.net/lorestore/AustLitTrail'">AustLit Trail</xsl:when>
                    	    <xsl:when test="//rdf:Description[@rdf:about = $ref]/layout:isPlaceholder=1">
                    	       <xsl:choose>
                    	           <xsl:when test="$reftitle"><xsl:value-of select="$reftitle"/></xsl:when>
                    	           <xsl:otherwise>(Placeholder)</xsl:otherwise>
                    	       </xsl:choose>
                    	    </xsl:when>
                    	    <xsl:when test="starts-with($ref,'http://purl.org/dc/dcmitype/')">
                               <a target="_blank" href="{$ref}"><xsl:value-of select="substring-after($ref,'http://purl.org/dc/dcmitype/')"/></a>
                            </xsl:when>
                    		<xsl:when test="$reftitle != ''">
                    			<a target="_blank" href="{$ref}"><xsl:value-of select="$reftitle"/><!--xsl:value-of select="java:aleg.ui.StylesheetFunctions.unescapeQuot($reftitle)"/--></a>
                    		</xsl:when>
                    		<xsl:when test="$ref">
                    			<a target="_blank" href="{$ref}"><xsl:value-of select="$ref"/></a>
                    		</xsl:when>
                    		<xsl:otherwise>
                    			<xsl:value-of select="@*"/>
                    		</xsl:otherwise>
                    	</xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                <br/>
             </xsl:if>
    </xsl:template>
    
    <xsl:template name="capitalize-first">
		<xsl:param name="str"/>
		<xsl:variable name="up" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
		<xsl:variable name="lo" select="'abcdefghijklmnopqrstuvwxyz'"/>
		<xsl:value-of select="translate(substring($str,1,1),$lo,$up)"/><xsl:value-of select="substring($str,2)"/>
	</xsl:template>
	
	<!--  suppress default template behaviour -->
    <xsl:template match="rdf:Description"/>
    
</xsl:stylesheet>