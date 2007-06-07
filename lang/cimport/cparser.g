/*
 * PUBLIC DOMAIN PCCTS-BASED C++ GRAMMAR (cplusplus.g, stat.g, expr.g)
 *
 * Authors: Sumana Srinivasan, NeXT Inc.;            sumana_srinivasan@next.com
 *          Terence Parr, Parr Research Corporation; parrt@parr-research.com
 *          Russell Quong, Purdue University;        quong@ecn.purdue.edu
 *
 * VERSION 1.2
 *
 * SOFTWARE RIGHTS
 *
 * This file is a part of the ANTLR-based C++ grammar and is free
 * software.  We do not reserve any LEGAL rights to its use or
 * distribution, but you may NOT claim ownership or authorship of this
 * grammar or support code.  An individual or company may otherwise do
 * whatever they wish with the grammar distributed herewith including the
 * incorporation of the grammar or the output generated by ANTLR into
 * commerical software.  You may redistribute in source or binary form
 * without payment of royalties to us as long as this header remains
 * in all source distributions.
 *
 * We encourage users to develop parsers/tools using this grammar.
 * In return, we ask that credit is given to us for developing this
 * grammar.  By "credit", we mean that if you incorporate our grammar or
 * the generated code into one of your programs (commercial product,
 * research project, or otherwise) that you acknowledge this fact in the
 * documentation, research report, etc....  In addition, you should say nice
 * things about us at every opportunity.
 *
 * As long as these guidelines are kept, we expect to continue enhancing
 * this grammar.  Feel free to send us enhancements, fixes, bug reports,
 * suggestions, or general words of encouragement at parrt@parr-research.com.
 * 
 * NeXT Computer Inc.
 * 900 Chesapeake Dr.
 * Redwood City, CA 94555
 * 12/02/1994
 * 
 * Restructured for public consumption by Terence Parr late February, 1995.
 *
 * DISCLAIMER: we make no guarantees that this grammar works, makes sense,
 *             or can be used to do anything useful.
 */
/* 2001-2002
 * Version 1.0
 * This C++ grammar file has been converted from PCCTS to run under 
 *  ANTLR to generate lexer and parser in C++ code by
 *  Jianguo Zuo and David Wigg at
 *  The Centre for Systems and Software Engineering
 *  London South Bank University
 *  London, UK.
 *
 */
/* 2003
 * Version 2.0 was published by David Wigg in September 2003
 */
/* 2004
 * Version 3.0 July 2004
 * This is version 3.0 of the C++ grammar definition for ANTLR to 
 *  generate lexer and parser in C++ code updated by
 *  David Wigg at
 *  The Centre for Systems and Software Engineering
 *  London South Bank University
 *  London, UK.
 *
 * wiggjd@bcs.ac.uk
 * blackse@lsbu.ac.uk
 *
 * See MyReadMe.txt for further information
 *
 * This file is best viewed in courier font with tabs set to 4 spaces
 */

header 
{
    // The statements in this block appear in both CPPLexer.hpp and CPPParser.hpp
    #include <antlr/CharScanner.hpp>
    #include "CPPDictionary.hh"
    #include <list>
}

options
{
    language = "Cpp";
}

class CPPParser extends Parser;

options
{
    k = 2;
    exportVocab = STDC;
    buildAST =false;
    codeGenMakeSwitchThreshold = 2;
    codeGenBitsetTestThreshold = 3;
    defaultErrorHandler=false;
}

{
public:
    // can't bitwise-OR enum elements together, this must be an int; damn!
    typedef long TypeSpecifier;
    enum TypeSpecifierEnum
    {
        tsInvalid  =0x0,
        tsVOID     =0x1,
        tsCHAR     =0x2,
        tsSHORT    =0x4,
        tsINT      =0x8,
        tsLONG     =0x10,
        tsFLOAT    =0x20,
        tsDOUBLE   =0x40,
        tsSIGNED   =0x80,
        tsUNSIGNED =0x100,
        tsTYPEID   =0x200,
        tsSTRUCT   =0x400,
        tsENUM     =0x800,
        tsUNION    =0x1000,
        tsCLASS    =0x2000,
        tsWCHAR_T  =0x4000,
        tsBOOL     =0x8000
    };

    enum TypeQualifier 
    { 
        tqInvalid=0, tqCONST=1, tqVOLATILE, tqCDECL 
    };

    enum StorageClass 
    {
        scInvalid=0, scAUTO=1, scREGISTER,
        scSTATIC, scEXTERN
    };

    enum DeclSpecifier 
    {
        dsInvalid=0,
        dsINLINE
    };

    // JEL 3/26/96 changed to allow ORing of values
    typedef long QualifiedItem;
    enum QualifiedItemEnum
    {
        qiInvalid    =0x0,
        qiType       =0x1,     // includes enum, class, typedefs, namespace
        qiVar        =0x20,
        qiFun        =0x40
    };

    // Limit lookahead for qualifiedItemIs()
    enum 
    { 
        MaxTemplateTokenScan = 200 
    };

protected:
    // Symbol table management stuff
    CPPDictionary *symbols;
    int externalScope;

    bool _td;			// For typedef
    StorageClass _sc;	// For storage class
    TypeQualifier _tq;	// For type qualifier
    TypeSpecifier _ts;	// For type specifier
    DeclSpecifier _ds;	// For declaration specifier

    int functionDefinition;	// 0 = Function definition not being parsed
    // 1 = Parsing function name
    // 2 = Parsing function parameter list
    // 3 = Parsing function block

    std::string qualifierPrefix;
    std::string enclosingClass;
    int assign_stmt_RHS_found;
    bool in_parameter_list;	// DW 13/02/04 used within CPP_parser
    bool in_return;
    bool is_address;
    int  pointer_level;

public:
    void init();
    ~CPPParser();

protected:
    // Semantic interface; You could subclass and redefine these functions
    //  so you don't have to mess with the grammar itself.

    // Symbol stuff
    virtual int isTypeName(const std::string& s);
    virtual void end_of_stmt();

    // Scoping stuff
    virtual void enterNewLocalScope();
    virtual void exitLocalScope();
    virtual void enterExternalScope();
    virtual void exitExternalScope();

    // Aggregate stuff
    virtual void classForwardDeclaration(TypeSpecifier, CPPParser::DeclSpecifier,const std::string&);
    virtual void beginClassDefinition(TypeSpecifier,const std::string&);
    virtual void endClassDefinition();
    virtual void beginEnumDefinition(const std::string&);
    virtual void enumElement(const std::string&, bool has_value, int value);
    virtual void endEnumDefinition();

    // Declaration and definition stuff
    virtual void declarationSpecifier(bool, StorageClass,TypeQualifier,TypeSpecifier,CPPParser::DeclSpecifier);
    virtual void beginDeclaration();
    virtual void endDeclaration();
    virtual void beginParameterDeclaration();
    virtual void beginFieldDeclaration();
    virtual void beginFunctionDefinition();
    virtual void endFunctionDefinition();
    virtual void functionParameterList();
    virtual void functionEndParameterList(const int def);

    // Declarator stuff
    virtual void declaratorID(const std::string&, QualifiedItem);	// This stores new symbol with its type.
    virtual void declaratorArray(int size);
    virtual void declaratorParameterList(const int def);
    virtual void declaratorEndParameterList(const int def);
    virtual void foundSimpleType(const std::list<std::string>& full_type);

}

translation_unit
:   { enterExternalScope(); }
    fragment
    EOF
    { exitExternalScope(); }
;

fragment
:
    (external_declaration)+
;

external_declaration
{std::string s; }
:
(     
      // Typedef, including typedef struct { } et al. 
        (("typedef")? class_head)=> declaration
|     // Enum definition (don't want to backtrack over this in other alts)
        ("enum" (ID)? LCURLY)=>
        enum_specifier (init_declarator_list)? SEMICOLON {end_of_stmt();}
|     // Function declaration
        (declaration_specifiers function_declarator[0] SEMICOLON)=> 
                declaration
|     // Function definition
        (declaration_specifiers	function_declarator[1] LCURLY)=> 
                function_definition
|     // everything else (except templates)
        declaration
| 	
        SEMICOLON {end_of_stmt();}
)
;	// end of external_declaration

function_definition
: { beginFunctionDefinition(); }
(       
        (declaration_specifiers) =>
                declaration_specifiers function_declarator[1]
                compound_statement
|       
        function_declarator[1] 
        compound_statement
) 
{ endFunctionDefinition(); }
;

declaration
:	
    ("extern" StringLiteral)=>
        linkage_specification
|	
    { beginDeclaration(); }
    declaration_specifiers ((COMMA)? init_declarator_list)? SEMICOLON { end_of_stmt();}
    { endDeclaration(); }
;

linkage_specification
:   "extern" StringLiteral 
    (
        LCURLY (external_declaration)* RCURLY
    | 
        declaration
    )
;

declaration_specifiers
{
    // Global flags to allow for nested declarations
    _td = false;		// For typedef
    _sc = scInvalid;	// For StorageClass
    _tq = tqInvalid;	// For TypeQualifier
    _ts = tsInvalid;	// For TypeSpecifier
    _ds = dsInvalid;	// For DeclSpecifier

    // Locals
    bool td = false;	// For typedef
    StorageClass sc = scInvalid;	// auto,register,static,extern,mutable
    TypeQualifier tq = tqInvalid;	// const,const_cast,volatile,cdecl
    TypeSpecifier ts = tsInvalid;	// char,int,double, etc., class,struct,union
    DeclSpecifier ds = dsInvalid;	// inline,virtual,explicit
}
:
(options {warnWhenFollowAmbig = false;}
:	sc = storage_class_specifier
|	tq = type_qualifier 
|	("inline"|"_inline"|"__inline")	   { ds = dsINLINE; }
|	"typedef"	{td=true;}			
|	("_stdcall"|"__stdcall")
|       "__extension__"
)*
ts = type_specifier[ds]

{declarationSpecifier(td,sc,tq,ts,ds);}
;

storage_class_specifier returns [CPPParser::StorageClass sc]
:	"auto"		{sc = scAUTO;}
|	"register"	{sc = scREGISTER;}
|	"static"	{sc = scSTATIC;}
|	"extern"	{sc = scEXTERN;}
;

type_qualifier returns [CPPParser::TypeQualifier tq] // aka cv_qualifier
:  ("__const"|"const"|"const_cast")	{tq = tqCONST;} 
|  "volatile"				{tq = tqVOLATILE;}
;

type_specifier[CPPParser::DeclSpecifier ds] returns [CPPParser::TypeSpecifier ts]
:	ts = simple_type_specifier
|	ts = class_specifier[ds]
|	enum_specifier	{ts=tsENUM;}
;

simple_type_specifier returns [CPPParser::TypeSpecifier ts]
{ 
    std::list<std::string> full_type; 
    std::string type;
    ts = tsInvalid;
}
:	( 
		(
                        (	"char"		{ts |= tsCHAR; full_type.push_back("char"); }
		        |	"wchar_t"	{ts |= tsWCHAR_T; full_type.push_back("wchar"); }  
		        |	"short"		{ts |= tsSHORT; full_type.push_back("short"); }
		        |	"int"		{ts |= tsINT; full_type.push_back("int"); }
		        |	("_int64"|"__int64")	{ts |= tsLONG; full_type.push_back("int64"); }
		        |	"__w64"		{ts |= tsLONG; full_type.push_back("int64"); }
		        |	"long"		{ts |= tsLONG; full_type.push_back("long"); }
		        |	"signed"	{ts |= tsSIGNED; full_type.push_back("signed"); }
		        |	"unsigned"	{ts |= tsUNSIGNED; full_type.push_back("unsigned"); }
		        |	"float"		{ts |= tsFLOAT; full_type.push_back("float"); }
		        |	"double"	{ts |= tsDOUBLE; full_type.push_back("double"); }
		        |	"void"		{ts |= tsVOID; full_type.push_back("void"); }
		        |	("_declspec"|"__declspec") LPAREN ID RPAREN 
		        ) 
                )+
	|
		// Fix towards allowing us to parse *.cpp files directly
		(qualified_type qualified_id) => type = qualified_type 
                {
                    ts=tsTYPEID;
                    full_type.push_back(type);
                }
	)
        { foundSimpleType(full_type); }
	;

qualified_type returns [std::string qitem]
		// JEL 3/29/96 removed this predicate and moved it upwards to
		// simple_type_specifier.  This was done to allow parsing of ~ID to 
		// be a unary_expression, which was never reached with this 
		// predicate on
		// {qualifiedItemIsOneOf(qiType|qiCtor)}?
        :
		id:ID 
		{ qitem = id->getText(); }
	;

member_declarator_list
        : member_declarator (COMMA member_declarator)*
        ;

member_declarator
  :
    ((ID)? COLON constant_expression)=>(ID)? COLON constant_expression
      | declarator
  ;

member_declaration
	:
	(
		(declaration_specifiers)=>
		{ beginFieldDeclaration(); }
		declaration_specifiers (member_declarator_list)? SEMICOLON {end_of_stmt();}
	|  
		SEMICOLON {end_of_stmt();}
	)
	;	// end member_declaration

class_specifier[CPPParser::DeclSpecifier ds] returns [CPPParser::TypeSpecifier ts]
	{std::string saveClass, id;}
	:	("struct"	{ts = tsSTRUCT;}
		|"union"	{ts = tsUNION;}
		)
		(	id = qualified_id
			( options{generateAmbigWarnings = false;}:
				{
                                    saveClass = enclosingClass;
				    enclosingClass = id;
				}
				LCURLY	 
				{ beginClassDefinition(ts, id); }	// This stores class name in dictionary
				(member_declaration)*
				{ endClassDefinition(); }
				RCURLY
				{enclosingClass = saveClass;}
			|
				{classForwardDeclaration(ts, ds, id);}
			)
		|
			LCURLY	 
			{
                            saveClass = enclosingClass; 
                            enclosingClass = "__anonymous";
                        }
			{ beginClassDefinition(ts, "anonymous"); }
			(member_declaration)*
			{ endClassDefinition(); }
			RCURLY
			{ enclosingClass = saveClass; }
		) 
	;

enum_specifier
	:	"enum"
		(	{ beginEnumDefinition(""); }
                        LCURLY enumerator_list RCURLY
			{ endEnumDefinition(); }
		|	id:ID     // DW 22/04/03 Suggest qualified_id here to satisfy elaborated_type_specifier
			{ beginEnumDefinition(id->getText()); }
			(LCURLY enumerator_list RCURLY)?
			{ endEnumDefinition(); }
		)
	;

enumerator_list
	:	enumerator (COMMA enumerator)*
	;

enumerator 
        { bool has_value = false; int value; }
/* We don't want to parse any enum definition. Limit to constant expressions */
/*	:	id:ID (ASSIGNEQUAL enum_value:constant_expression  */
  	:	id:ID (ASSIGNEQUAL value = int_constant_expression { has_value = true; })?
		{ enumElement(id->getText(), has_value, value); }
	;

/* This matches a generic qualified identifier ::T::B::foo
 * (including OPERATOR).
 * It might be a good idea to put T::~dtor in here
 * as well, but id_expression in expr.g puts it in manually.
 * Maybe not, 'cause many people use this assuming only A::B.
 * How about a 'qualified_complex_id'?
 */
qualified_id returns [std::string qitem]
	: id:ID	
	{ qitem = id->getText(); }
	;

typeID
	:	{ isTypeName(LT(1)->getText()) }?
		ID
	;

init_declarator_list
	:	init_declarator (COMMA init_declarator)*
	;

init_declarator
	:	declarator 
		(	
			ASSIGNEQUAL 
			initializer
		|	
			LPAREN expression_list RPAREN
		)?
	;

initializer
   :  remainder_expression // DW 18/4/01 assignment_expression
   |  LCURLY initializer (COMMA initializer)* RCURLY
   ;

class_head
	:	// Used only by predicates	
	("struct"  
	|"union")
    (ID)? LCURLY
	;

// JEL note:  does not use (const|volatile)* to avoid lookahead problems
cv_qualifier_seq
	{CPPParser::TypeQualifier tq;}
	:
	(tq = type_qualifier)*
	;

declarator
	:
		//{( !(LA(1)==SCOPE||LA(1)==ID) || qualifiedItemIsOneOf(qiPtrMember) )}?
		(ptr_operator)=> ptr_operator	// AMPERSAND or STAR
                { ++pointer_level; }
		declarator
	|	
		direct_declarator
	;

direct_declarator
	{
            std::string id;
            int array_size = 0;
        }  
	:
		(qualified_id LPAREN (RPAREN|declaration_specifiers) )=>	// Must be function declaration
                function_direct_declarator[0]
	|
		(qualified_id LSQUARE)=>	// Must be array declaration
		id = qualified_id
                { 
                    if (_td==true)
			declaratorID(id,qiType);
		    else
			declaratorID(id,qiVar);
		    is_address = false; pointer_level = 0;
		}
		(
                    options {warnWhenFollowAmbig = false;}:
		    LSQUARE { array_size = 0; }
                    (  
                        (array_size = int_constant_expression)? 
                    )   { declaratorArray(array_size); }
                    RSQUARE
                )+
	|
		id = qualified_id
		{ 
                    if (_td==true)
			declaratorID(id,qiType);
		    else
			declaratorID(id,qiVar);
		    is_address = false; pointer_level = 0;
		}
	|	
		LPAREN declarator RPAREN declarator_suffixes
	;

declarator_suffixes
	{
            CPPParser::TypeQualifier tq;
            int array_size = 0;
        } 
	:
	(
		(
                    options {warnWhenFollowAmbig = false;}:
		    LSQUARE { array_size = 0; }
                    (  
                        (array_size = int_constant_expression)? 
                    )   { declaratorArray(array_size); }
                    RSQUARE
                )+
	|	
		LPAREN {declaratorParameterList(0);}
		(parameter_list)?
		RPAREN {declaratorEndParameterList(0);}
		(tq = type_qualifier)*
                (gcc_attribute_specification)*
	)
	;

/* I think something is weird with the context-guards for predicates;
 * as a result I manually hoist the appropriate pred from ptr_to_member
 *
 * TER: warning: seems that "ID::" will always bypass and go to 2nd alt :(
 */
function_declarator [int definition]
	:	
		//{( !(LA(1)==SCOPE||LA(1)==ID) || qualifiedItemIsOneOf(qiPtrMember) )}?
		(ptr_operator)=> ptr_operator function_declarator[definition]
	|	
		function_direct_declarator[definition]
	;

function_direct_declarator [int definition] 
	{std::string qitem;
	 CPPParser::TypeQualifier tq;}
	:
		/* predicate indicate that plain ID is ok here; this counteracts any
		 * other predicate that gets hoisted (along with this one) that
		 * indicates that an ID is a type or whatever.  E.g.,
		 * another rule testing isTypeName() alone, implies that the
		 * the ID *MUST* be a type name.  Combining isTypeName() and
		 * this predicate in an OR situation like this one:
		 * ( declaration_specifiers ... | function_declarator ... )
		 * would imply that ID can be a type name OR a plain ID.
		 */
		(	// fix prompted by (isdigit)() in xlocnum
			LPAREN
			qitem = qualified_id
			{ declaratorID(qitem, qiFun); }
			RPAREN
		|
			qitem = qualified_id
			{ declaratorID(qitem, qiFun); }
		)

		LPAREN 
		{
		    functionParameterList();
                    in_parameter_list = true;
		}
		(parameter_list)? 
		{
                    in_parameter_list = false;
		}
		RPAREN
		(tq = type_qualifier)*
		{ functionEndParameterList(definition); }
                (gcc_attribute_specification)*
	;

parameter_list
	:	parameter_declaration 
		( // Have not been able to find way of stopping warning of non-determinism between alt 1 and exit branch of block
		    COMMA parameter_declaration )*
	;

parameter_declaration
	:	{beginParameterDeclaration();}
		(
			declaration_specifiers	// DW 24/3/98 Mods for K & R
			(  
				(declarator)=> declarator        // if arg name given
			| 
				abstract_declarator     // if arg name not given  // can be empty
			)
		|
			ELLIPSIS
		)
	;

type_name // aka type_id
	:
	declaration_specifiers abstract_declarator
	;

/* This rule looks a bit weird because (...) can happen in two
 * places within the declaration such as "void (*)()" (ptr to
 * function returning nothing).  However, the () of a function
 * can only occur after having seen either a (abstract_declarator)
 * and not after a [..] or simple '*'.  These are the only two
 * valid () func-groups:
 *    int (*)();     // ptr to func
 *    int (*[])();   // array of ptr to func
 */
abstract_declarator
        { int array_size = 0; }
	:	//{( !(LA(1)==SCOPE||LA(1)==ID) || qualifiedItemIsOneOf(qiPtrMember) )}?
		ptr_operator abstract_declarator 
	|	
		LPAREN abstract_declarator RPAREN
		(abstract_declarator_suffix)+
	|	
		(
                    LSQUARE  { array_size = 0; }
                    (array_size = int_constant_expression)? 
                    RSQUARE 
                    { declaratorArray(array_size); }
		)+
	|	
		/* empty */
	;

abstract_declarator_suffix
        { int array_size = 0; }
	:	
               LSQUARE  { array_size = 0; }
               (array_size = int_constant_expression)? 
               RSQUARE 
               { declaratorArray(array_size); }
	|
		LPAREN
		{declaratorParameterList(0);}
		(parameter_list)?
		RPAREN
		{declaratorEndParameterList(0);}
	;

gcc_attribute_specification
    : "__attribute__" LPAREN LPAREN
    ("__format_args__" LPAREN Decimal RPAREN
    |"__const__")
    RPAREN RPAREN
    ;

/* This is to allow an assigned type_name in a template parameter
 *	list to be defined previously in the same parameter list,
 *	as type setting is ineffective whilst guessing
 */
assigned_type_name
	{std::string s; TypeSpecifier ts;}
	:
	(options{generateAmbigWarnings = false;}:
		s = qualified_type abstract_declarator	
	|
		ts = simple_type_specifier abstract_declarator
	)
	;

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
//////////////////////////////  STATEMENTS ////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

statement_list
	:	(statement)+
	;

statement
	:
	(	(declaration)=> declaration 
	|	labeled_statement
	|	case_statement
	|	default_statement
	|	expression SEMICOLON {end_of_stmt();}
	|	compound_statement
	|	selection_statement
	|	iteration_statement
	|	jump_statement
	|	SEMICOLON {end_of_stmt();}
	|	asm_block
	)
	;

labeled_statement
	:	ID COLON statement
	;

case_statement
	:	"case"
		constant_expression COLON statement
	;

default_statement
	:	"default" COLON statement
	;

compound_statement
	:	LCURLY {end_of_stmt();
				enterNewLocalScope();
			   }
		(statement_list)?
		RCURLY {exitLocalScope();}
	;

/* NOTE: cannot remove ELSE ambiguity, but it parses correctly.
 * The warning is removed with the options statement
 */
selection_statement
	:	
		"if" LPAREN 
		expression RPAREN
		statement
		(options {warnWhenFollowAmbig = false;}:
		 "else" statement)?
	|	
		"switch" LPAREN  expression RPAREN statement
	;

iteration_statement
	:	
		"while"	
		LPAREN expression RPAREN 
		statement  
	|	
		"do" 
		statement "while"
		LPAREN expression RPAREN 
		SEMICOLON {end_of_stmt();} 
	|	
		"for" LPAREN
		(	(declaration)=> declaration 
		|	expression SEMICOLON {end_of_stmt();}
		|	SEMICOLON {end_of_stmt();} 
		)
		(expression)? SEMICOLON {end_of_stmt();}
		(expression)?
		RPAREN statement	 
	;

jump_statement
	:	
	(	"goto" ID SEMICOLON {end_of_stmt();}
	|	"continue" SEMICOLON {end_of_stmt();}
	|	"break" SEMICOLON {end_of_stmt();}
		// DW 16/05/03 May be problem here if return is followed by a cast expression 
	|	"return" {in_return = true;}
		(	options{warnWhenFollowAmbig = false;}:
			(LPAREN ID RPAREN)=> 
			LPAREN ID RPAREN (expression)?	// This is an unsatisfactory fix for problem in xstring re "return (allocator);"
											//  and in xlocale re return (_E)(_Tolower((unsigned char)_C, &_Ctype));
			//{printf("%d CPP_parser.g jump_statement Return fix used\n",LT(1)->getLine());}
		|	expression 
		)?	SEMICOLON {in_return = false,end_of_stmt();} 
	)
	;

asm_block 	
	:	("_asm"|"__asm") LCURLY (~RCURLY)* RCURLY 
	;

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
//////////////////////////////  EXPRESSIONS ///////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

expression
	:	assignment_expression (COMMA assignment_expression)*
	;

/* right-to-left for assignment op */
assignment_expression
	:	conditional_expression
		(	(ASSIGNEQUAL|TIMESEQUAL|DIVIDEEQUAL|MINUSEQUAL|PLUSEQUAL
			|MODEQUAL
			|SHIFTLEFTEQUAL
			|SHIFTRIGHTEQUAL
			|BITWISEANDEQUAL
			|BITWISEXOREQUAL
			|BITWISEOREQUAL
			)
			remainder_expression
		)?
	;

remainder_expression
	:
		(	(conditional_expression (COMMA|SEMICOLON|RPAREN)
			)=>
			{assign_stmt_RHS_found += 1;}
			assignment_expression
			{
			if (assign_stmt_RHS_found > 0)
				assign_stmt_RHS_found -= 1;
			else
				{
				printf("%d warning Error in assign_stmt_RHS_found = %d\n",
					LT(1)->getLine(),assign_stmt_RHS_found);
				printf("Press return to continue\n");
				getchar();
				}
			}
		|	
			assignment_expression
		)
	;

conditional_expression
	:	
		logical_or_expression
		(QUESTIONMARK expression COLON conditional_expression)?
	;

constant_expression
	:	
		conditional_expression
	;

logical_or_expression
	:	
		logical_and_expression (OR logical_and_expression)* 
	;

logical_and_expression
	:	
		inclusive_or_expression (AND inclusive_or_expression)* 
	;

inclusive_or_expression
	:	
		exclusive_or_expression (BITWISEOR exclusive_or_expression)*
	;

exclusive_or_expression
	:	
		and_expression (BITWISEXOR and_expression)*
	;

and_expression
	:	
	equality_expression (AMPERSAND  equality_expression)*
	;

equality_expression
	:	
		relational_expression ((NOTEQUAL | EQUAL) relational_expression)*
	;

relational_expression
	:	shift_expression
		(options {warnWhenFollowAmbig = false;}:
			(	LESSTHAN
			|	GREATERTHAN
			|	LESSTHANOREQUALTO
			|	GREATERTHANOREQUALTO
			)
		 shift_expression
		)*
	;

shift_expression
	:	additive_expression ((SHIFTLEFT | SHIFTRIGHT) additive_expression)*
	;

/* See comment for multiplicative_expression regarding #pragma */
additive_expression
	:	multiplicative_expression
		(options{warnWhenFollowAmbig = false;}:
			(PLUS | MINUS) multiplicative_expression
		)*
	;

/* ANTLR has trouble dealing with the analysis of the confusing unary/binary
 * operators such as STAR, AMPERSAND, PLUS, etc...  With the #pragma (now "(options{warnWhenFollowAmbig = false;}:" etc.)
 * we simply tell ANTLR to use the "quick-to-analyze" approximate lookahead
 * as full LL(k) lookahead will not resolve the ambiguity anyway.  Might
 * as well not bother.  This has the side-benefit that ANTLR doesn't go
 * off to lunch here (take infinite time to read grammar).
 */
multiplicative_expression
	:	pm_expression
		(options{warnWhenFollowAmbig = false;}:
			(STAR | DIVIDE | MOD) pm_expression
		)*
	;

pm_expression
	:	cast_expression ((DOTMBR | POINTERTOMBR) cast_expression)*
	;

/* The string "( ID" can be either the start of a cast or
 * the start of a unary_expression.  However, the ID must
 * be a type name for it to be a cast.  Since ANTLR can only hoist
 * semantic predicates that are visible without consuming a token,
 * the semantic predicate in rule type_name is not hoisted--hence, the
 * rule is reported to be ambiguous.  I am manually putting in the
 * correctly hoisted predicate.
 *
 * Ack! Actually "( ID" might be the start of "(T(expr))" which makes
 * the first parens just an ordinary expression grouping.  The solution
 * is to look at what follows the type, T.  Note, this could be a
 * qualified type.  Yucko.  I believe that "(T(" can only imply
 * function-style type cast in an expression (...) grouping.
 *
 * We DO NOT handle the following situation correctly at the moment:
 * Suppose you have
 *    struct rusage rusage;
 *    return (rusage.fp);
 *    return (rusage*)p;
 * Now essentially there is an ambiguity here. If rusage is followed by any
 * postix operators then it is an identifier else it is a type name. This
 * problem does not occur in C because, unless the tag struct is attached,
 * rusage is not a type name. However in C++ that restriction is removed.
 * No *real* programmer would do this, but it's in the C++ standard just for
 * fun..
 *
 * Another fun one (from an LL standpoint):
 *
 *   (A::B::T *)v;      // that's a cast of v to type A::B::T
 *   (A::B::foo);    // that's a simple member access
 *
 * The qualifiedItemIs(1) function scans ahead to what follows the
 * final "::" and returns qiType if the item is a type.  The offset of
 * '1' makes it ignore the initial LPAREN; normally, the offset is 0.
 */

cast_expression 
	{TypeQualifier tq;
	 TypeSpecifier ts;}
	:
		// DW 23/06/03
		(LPAREN (type_qualifier)? simple_type_specifier (ptr_operator)? RPAREN)=>
		 LPAREN (tq = type_qualifier)? ts = simple_type_specifier (ptr_operator)? RPAREN cast_expression
	|  
		unary_expression	// handles outer (...) of "(T(expr))"
	;

unary_expression
	:
		(	//{!(LA(1)==TILDE && LA(2)==ID)||qualifiedItemIsOneOf(qiVar|qiFun|qiDtor|qiCtor)}?
			(postfix_expression)=> postfix_expression
		|	PLUSPLUS unary_expression
		|	MINUSMINUS unary_expression
		|	unary_operator cast_expression
		|	"sizeof"
			(// see comment for rule cast_expression for info on predicate
			 // JEL NOTE 3/31/96 -- This won't work -- you really need to
			 // call qualifiedItemIsOneOf(qiType|qiCtor,1)
			 // The context should also be ( LPAREN (SCOPE|ID) )
			 //	( LPAREN ID ) => {isTypeName((LT(2)->getText()).data())}?
			 {(!(((LA(1)==LPAREN&&(LA(2)==ID))))||(isTypeName(LT(2)->getText())))}?
				LPAREN type_name RPAREN
			|	unary_expression
			)
		)
	;

postfix_expression
	{TypeSpecifier ts;
	 CPPParser::DeclSpecifier ds = dsInvalid;	// Purpose ?
	}
	:
	(	
		options {warnWhenFollowAmbig = false;}:
		// Function-style cast must have a leading type
		{!(LA(1)==LPAREN)}?
		(ts = simple_type_specifier LPAREN RPAREN LPAREN)=>	// DW 01/08/03 To cope with problem in xtree (see test10.i)
		 ts = simple_type_specifier LPAREN RPAREN LPAREN (expression_list)? RPAREN
	|
		{!(LA(1)==LPAREN)}?
		(ts = simple_type_specifier LPAREN)=>
		 ts = simple_type_specifier LPAREN (expression_list)? RPAREN
	|  
		primary_expression
		(options {warnWhenFollowAmbig = false;}:
        	LSQUARE expression RSQUARE
		|	LPAREN (expression_list)? RPAREN 
		|	DOT id_expression
		|	POINTERTO id_expression
		|	PLUSPLUS 
		|	MINUSMINUS
		)*
	|
		("dynamic_cast"|"static_cast"|"reinterpret_cast"|"const_cast")	// Note const_cast in elsewhere
		LESSTHAN ts = type_specifier[ds] (ptr_operator)? GREATERTHAN
		LPAREN expression RPAREN
	)
	;

primary_expression
	:	id_expression
	|	constant
	|	LPAREN expression RPAREN
	;

id_expression 
	:
	ID
	;

unary_operator
	:	AMPERSAND
	|	STAR
	|	PLUS
	|	MINUS
	|	TILDE
	|	NOT
	;

ptr_operator
	:	(	AMPERSAND 	{is_address = true;}
                |       STAR
		|	("_cdecl"|"__cdecl") 
		|	("_near"|"__near") 
		|	("_far"|"__far") 
		|	"__interrupt" 
		|	("pascal"|"_pascal"|"__pascal") 
		|	("_stdcall"|"__stdcall") 
                |       "__restrict"
		)	
   ;

expression_list
	:	assignment_expression (COMMA assignment_expression)*
	;

constant
	:	OCTALINT
	|	DECIMALINT
	|	HEXADECIMALINT
	|	CharLiteral
	|	(StringLiteral)+
	|	FLOATONE
	|	FLOATTWO
	;




int_constant_expression returns [ int value ]
        : value = int_constant_add_expression
        ;

int_constant_add_expression returns [ int value ]
        { int opval, sign; }
        : value = int_constant_mult_expression
        ( (PLUS { sign = 1; } | MINUS { sign = -1; })
            opval = int_constant_mult_expression { value += sign * opval; }
        )*
        ;

int_constant_mult_expression returns [ int value ]
        { int opval; }
        : value = int_constant_shift_expression
        ( STAR opval = int_constant_shift_expression { value *= opval; }
        | DIVIDE  opval = int_constant_shift_expression { value /= opval; }
        )*
        ;

int_constant_shift_expression returns [ int value ]
        { int shiftval; }
        : value = int_constant_primary_expression
        ( SHIFTLEFT shiftval  = int_constant_primary_expression { value <<= shiftval; }
        | SHIFTRIGHT shiftval = int_constant_primary_expression { value >>= shiftval; }
        )*
        ;

int_constant_primary_expression returns [ int value ]
        : value = int_constant_unary_expression
        | LPAREN value = int_constant_expression RPAREN
        ;

int_constant_unary_expression returns [ int value ]
        { int sign; }
        : (PLUS { sign = 1; }|MINUS { sign = -1; }) value = int_constant_unary_expression { value *= sign; }
        | value = int_constant
        ;


int_constant returns [ int value ]
        :       
                oct:OCTALINT       { value = strtol(oct->getText().data(), NULL, 0); }
        |       dec:DECIMALINT     { value = strtol(dec->getText().data(), NULL, 0); }
        |       hex:HEXADECIMALINT { value = strtol(hex->getText().data(), NULL, 0); }
         
        ;

optor 
	:
	|	LPAREN RPAREN
	|	LSQUARE RSQUARE
	|	optor_simple_tokclass	//OPTOR_SIMPLE_TOKCLASS
	;

//Zuo 5/11/2001
// This is the equivalent to "#tokclass OPTOR_SIMPLE_TOKCLASS" in cplusplus.g

optor_simple_tokclass
	:
    (PLUS|MINUS|STAR|DIVIDE|MOD|BITWISEXOR|AMPERSAND|BITWISEOR|TILDE|NOT|
	 SHIFTLEFT|SHIFTRIGHT|
	 ASSIGNEQUAL|TIMESEQUAL|DIVIDEEQUAL|MODEQUAL|PLUSEQUAL|MINUSEQUAL|
	 SHIFTLEFTEQUAL|SHIFTRIGHTEQUAL|BITWISEANDEQUAL|BITWISEXOREQUAL|BITWISEOREQUAL|
	 EQUAL|NOTEQUAL|LESSTHAN|GREATERTHAN|LESSTHANOREQUALTO|GREATERTHANOREQUALTO|OR|AND|
	 PLUSPLUS|MINUSMINUS|COMMA|POINTERTO|POINTERTOMBR
	)
	;

// Zuo 19/11/01 from next line, the Lexer is derived from stdCParser.g

class CPPLexer extends Lexer;

options
{
	k = 3;
	importVocab = STDC;
	testLiterals = false;
        defaultErrorHandler=false;
}

// DW 4/11/02 put in to support manual hoisting
{
    ANTLR_USE_NAMESPACE(std)string originalSource;
    int deferredLineCount;
    
    int	_line;
    
    void setOriginalSource(ANTLR_USE_NAMESPACE(std)string src) 
    {
    	//originalSource = src;
    	//lineObject.setSource(src);
    }
    
    void setSource(ANTLR_USE_NAMESPACE(std)string src)
    { 
        //lineObject.setSource(src); 
    }
    
    void deferredNewline() { deferredLineCount++; }
    void newline() { CharScanner::newline(); }
}

/* Operators: */

ASSIGNEQUAL     : '=' ;
COLON           : ':' ;
COMMA           : ',' ;
QUESTIONMARK    : '?' ;
SEMICOLON       : ';' ;
POINTERTO       : "->" ;

/*
// DOT & ELLIPSIS are commented out since they are generated as part of
// the Number rule below due to some bizarre lexical ambiguity shme.
// DOT  :       '.' ;
// ELLIPSIS      : "..." ;
*/

LPAREN          : '(' ;
RPAREN          : ')' ;
LSQUARE         : '[' ;
RSQUARE         : ']' ;
LCURLY          : '{' ;
RCURLY          : '}' ;

EQUAL           : "==" ;
NOTEQUAL        : "!=" ;
LESSTHANOREQUALTO     : "<=" ;
LESSTHAN              : "<" ;
GREATERTHANOREQUALTO  : ">=" ;
GREATERTHAN           : ">" ;

DIVIDE          : '/' ;
DIVIDEEQUAL     : "/=" ;
PLUS            : '+' ;
PLUSEQUAL       : "+=" ;
PLUSPLUS        : "++" ;
MINUS           : '-' ;
MINUSEQUAL      : "-=" ;
MINUSMINUS      : "--" ;
STAR            : '*' ;
TIMESEQUAL      : "*=" ;
MOD             : '%' ;
MODEQUAL        : "%=" ;
SHIFTRIGHT      : ">>" ;
SHIFTRIGHTEQUAL : ">>=" ;
SHIFTLEFT       : "<<" ;
SHIFTLEFTEQUAL  : "<<=" ;

AND            : "&&" ;
NOT            : '!' ;
OR             : "||" ;

AMPERSAND       : '&' ;
BITWISEANDEQUAL : "&=" ;
TILDE           : '~' ;
BITWISEOR       : '|' ;
BITWISEOREQUAL  : "|=" ;
BITWISEXOR      : '^' ;
BITWISEXOREQUAL : "^=" ;

//Zuo: the following tokens are come from cplusplus.g

POINTERTOMBR    : "->*" ;
DOTMBR          : ".*"  ;

SCOPE           : "::"  ;

// DW 10/10/02
// Whitespace -- ignored
Whitespace	
	:	(	(' ' |'\t' | '\f')
			// handle newlines
		|	(	"\r\n"  // MS
			|	'\r'    // Mac
			|	'\n'    // Unix 
			)	{ newline(); }
			// handle continuation lines
		|	(	"\\\r\n"  // MS
			|	"\\\r"    // Mac
			|	"\\\n"    // Unix 
			)	{deferredNewline();}
		)	
		{_ttype = ANTLR_USE_NAMESPACE(antlr)Token::SKIP;}
	;

Comment  
	:	"/*"   
		(	{LA(2) != '/'}? '*'
		|	EndOfLine {deferredNewline();}
		|	~('*'| '\r' | '\n')
		)*
		"*/" {_ttype = ANTLR_USE_NAMESPACE(antlr)Token::SKIP;}
	;

CPPComment
	:	"//" (~('\n' | '\r'))* EndOfLine
 		{_ttype = ANTLR_USE_NAMESPACE(antlr)Token::SKIP; newline();}                     
	;

PREPROC_DIRECTIVE
	options{paraphrase = "a line directive";}
	:	'#' LineDirective
		{_ttype = ANTLR_USE_NAMESPACE(antlr)Token::SKIP; newline();} 
	;

protected 
LineDirective
:
    ("line")?  // this would be for if the directive started "#line"
    (Space)+
    n:Decimal
    (
        Space sl:StringLiteral
        (Space Decimal)*
    )?
    EndOfLine
;

protected  
Space
:	(' ' | '\t' | '\f')
;


Pragma
:	('#' "pragma" (~('\r' | '\n'))* EndOfLine)
	{_ttype = ANTLR_USE_NAMESPACE(antlr)Token::SKIP; newline();}
;

Error
:	('#' "error" (~('\r' | '\n'))* EndOfLine)
	{_ttype = ANTLR_USE_NAMESPACE(antlr)Token::SKIP; newline();}
;

/* Literals: */

/*
 * Note that we do NOT handle tri-graphs nor multi-byte sequences.
 */

/*
 * Note that we can't have empty character constants (even though we
 * can have empty strings :-).
 */
CharLiteral
	:	'\'' (Escape | ~( '\'' )) '\''
	;

/*
 * Can't have raw imbedded newlines in string constants.  Strict reading of
 * the standard gives odd dichotomy between newlines & carriage returns.
 * Go figure.
 */
StringLiteral
	:	'"'
		( Escape
		|	(	"\\\r\n"   // MS 
			|	"\\\r"     // MAC
			|	"\\\n"     // Unix
			)	{deferredNewline();}
		|	~('"' | '\r' | '\n' | '\\')
		)*
		'"'
	;

protected
EndOfLine
	:	(	options{generateAmbigWarnings = false;}:
			"\r\n"  // MS
		|	'\r'    // Mac
		|	'\n'    // Unix
		)
	;

/*
 * Handle the various escape sequences.
 *
 * Note carefully that these numeric escape *sequences* are *not* of the
 * same form as the C language numeric *constants*.
 *
 * There is no such thing as a binary numeric escape sequence.
 *
 * Octal escape sequences are either 1, 2, or 3 octal digits exactly.
 *
 * There is no such thing as a decimal escape sequence.
 *
 * Hexadecimal escape sequences are begun with a leading \x and continue
 * until a non-hexadecimal character is found.
 *
 * No real handling of tri-graph sequences, yet.
 */

protected
Escape  
	:	'\\'
		( options{warnWhenFollowAmbig=false;}:
		  'a'
		| 'b'
		| 'f'
		| 'n'
		| 'r'
		| 't'
		| 'v'
		| '"'
		| '\''
		| '\\'
		| '?'
		| ('0'..'3') (options{warnWhenFollowAmbig=false;}: Digit (options{warnWhenFollowAmbig=false;}: Digit)? )?
		| ('4'..'7') (options{warnWhenFollowAmbig=false;}: Digit)?
		| 'x' (options{warnWhenFollowAmbig=false;}: Digit | 'a'..'f' | 'A'..'F')+
		)
	;

/* Numeric Constants: */

protected
Digit
	:	'0'..'9'
	;

protected
Decimal
	:	('0'..'9')+
	;

protected
LongSuffix
	:	'l'
	|	'L'
	;

protected
UnsignedSuffix
	:	'u'
	|	'U'
	;

protected
FloatSuffix
	:	'f'
	|	'F'
	;

protected
Exponent
	:	('e' | 'E') ('+' | '-')? (Digit)+
	;

protected
Vocabulary
	:	'\3'..'\377'
	;

Number
	:	( (Digit)+ ('.' | 'e' | 'E') )=> (Digit)+
		( '.' (Digit)* (Exponent)? {_ttype = FLOATONE;} //Zuo 3/12/01
		| Exponent                 {_ttype = FLOATTWO;} //Zuo 3/12/01
		)                          //{_ttype = DoubleDoubleConst;}
		(FloatSuffix               //{_ttype = FloatDoubleConst;}
		|LongSuffix                //{_ttype = LongDoubleConst;}
		)?

	|	("...")=> "..."            {_ttype = ELLIPSIS;}

	|	'.'                        {_ttype = DOT;}
		(	(Digit)+ (Exponent)?   {_ttype = FLOATONE;} //Zuo 3/12/01
                                   //{_ttype = DoubleDoubleConst;}
			(FloatSuffix           //{_ttype = FloatDoubleConst;}
			|LongSuffix            //{_ttype = LongDoubleConst;}
			)?
		)?

	|	'0' ('0'..'7')*            //{_ttype = IntOctalConst;}
		(LongSuffix                //{_ttype = LongOctalConst;}
		|UnsignedSuffix            //{_ttype = UnsignedOctalConst;}
		)*                         {_ttype = OCTALINT;}

	|	'1'..'9' (Digit)*          //{_ttype = IntIntConst;}
		(LongSuffix                //{_ttype = LongIntConst;}
		|UnsignedSuffix            //{_ttype = UnsignedIntConst;}
		)*                         {_ttype = DECIMALINT;}  

	|	'0' ('x' | 'X') ('a'..'f' | 'A'..'F' | Digit)+
                                   //{_ttype = IntHexConst;}
		(LongSuffix                //{_ttype = LongHexConst;}
		|UnsignedSuffix            //{_ttype = UnsignedHexConst;}
		)*                         {_ttype = HEXADECIMALINT;}   
	;

ID
options { testLiterals=true; }
:
    ( 'a'..'z' | 'A'..'Z' | '_' )
    ( 'a'..'z' | 'A'..'Z' | '_' | '0'..'9' )*
;

// vim:ts=8
