/**
 * visitor/general.d
 * call the visit method of the super class if the visit for this class is not overridden.
 */
module visitor.general;

import ast.ast;
import visitor.visitor;

class GeneralVisitor : Visitor {
	/* astnode.d */
    override void visit(ASTNode x) { }
	
    /* aggregate.d */
    override void visit(AggregateDeclaration x) { visit(cast(ScopeSymbol)x); }

	/* declaration.d */
	override void visit(LetDeclaration x) { visit(cast(Symbol)x); }
	override void visit(TypedefDeclaration x) { visit(cast(Symbol)x); }
	override void visit(ImportDeclaration x) { visit(cast(Symbol)x); }
	override void visit(AliasImportDeclaration x) { visit(cast(ImportDeclaration)x); }
	override void visit(BindedImportDeclaration x) { visit(cast(ImportDeclaration)x); }

    /* expression.d */
    override void visit(Expression x) { visit(cast(ASTNode)x); }
    override void visit(BinaryExpression x) { visit(cast(Expression)x); }
    override void visit(AssExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(BinaryAssExpression x) { visit(cast(BinaryExpression)x); }
	override void visit(AddAssExpression x) { visit(cast(BinaryAssExpression)x); }
    override void visit(SubAssExpression x) { visit(cast(BinaryAssExpression)x); }
    override void visit(CatAssExpression x) { visit(cast(BinaryAssExpression)x); }
    override void visit(MulAssExpression x) { visit(cast(BinaryAssExpression)x); }
    override void visit(DivAssExpression x) { visit(cast(BinaryAssExpression)x); }
    override void visit(ModAssExpression x) { visit(cast(BinaryAssExpression)x); }
    override void visit(PowAssExpression x) { visit(cast(BinaryAssExpression)x); }
    override void visit(BitAndAssExpression x) { visit(cast(BinaryAssExpression)x); }
    override void visit(BitXorAssExpression x) { visit(cast(BinaryAssExpression)x); }
    override void visit(BitOrAssExpression x) { visit(cast(BinaryAssExpression)x); }
    override void visit(PipelineExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(AppExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(OrExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(XorExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(AndExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(BitOrExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(BitXorExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(BitAndExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(EqExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(NeqExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(LsExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(LeqExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(GtExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(GeqExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(NisExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(InExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(NinExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(AddExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(SubExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(CatExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(MulExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(DivExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(ModExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(LShiftExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(RShiftExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(LogicalShiftExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(PowExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(ApplyExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(CompositionExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(DotExpression x) { visit(cast(BinaryExpression)x); }
    override void visit(UnaryExpression x) { visit(cast(Expression)x); }
    override void visit(MinusExpression x) { visit(cast(UnaryExpression)x); }
    override void visit(NotExpression x) { visit(cast(UnaryExpression)x); }
    override void visit(RefofExpression x) { visit(cast(UnaryExpression)x); }
    override void visit(DerefExpression x) { visit(cast(UnaryExpression)x); }
    override void visit(IndexingExpression x) { visit(cast(Expression)x); }
    override void visit(SlicingExpression x) { visit(cast(Expression)x); }
    override void visit(AscribeExpression x) { visit(cast(Expression)x); }
    override void visit(WhenElseExpression x) { visit(cast(Expression)x); }
    override void visit(IntegerExpression x) { visit(cast(Expression)x); }
    override void visit(RealNumberExpression x) { visit(cast(Expression)x); }
    override void visit(StringExpression x) { visit(cast(Expression)x); }
    override void visit(IdentifierExpression x) { visit(cast(Expression)x); }
    override void visit(AnyExpression x) { visit(cast(Expression)x); }
    override void visit(FalseExpression x) { visit(cast(Expression)x); }
    override void visit(TrueExpression x) { visit(cast(Expression)x); }
    override void visit(NullExpression x) { visit(cast(Expression)x); }
    override void visit(ThisExpression x) { visit(cast(Expression)x); }
    override void visit(SuperExpression x) { visit(cast(Expression)x); }
    override void visit(DollarExpression x) { visit(cast(Expression)x); }
    override void visit(UnitExpression x) { visit(cast(Expression)x); }
    override void visit(TupleExpression x) { visit(cast(Expression)x); }
    override void visit(NewExpression x) { visit(cast(Expression)x); }
    override void visit(ArrayExpression x) { visit(cast(Expression)x); }
    override void visit(AArrayExpression x) { visit(cast(Expression)x); }
    override void visit(BuiltInTypePropertyExpression x) { visit(cast(Expression)x); }
    override void visit(TemplateInstanceExpression x) { visit(cast(Expression)x); }
    override void visit(TypeidExpression x) { visit(cast(Expression)x); }
	override void visit(MixinExpression x) { visit(cast(Expression)x); }
	
	/* func.d */
	override void visit(FuncArgument x) { visit(cast(Symbol)x); }
	override void visit(FuncDeclaration x) { visit(cast(ScopeSymbol)x); }

	/* mixin_.d */
	override void visit(Mixin x) { visit(cast(ASTNode)x); }

	/* module_.d */
	override void visit(Module x) { visit(cast(ScopeSymbol)x); }
	override void visit(Package x) { visit(cast(ScopeSymbol)x); }

    /* statement.d */
	override void visit(Statement x) { visit(cast(ASTNode)x); }
	override void visit(DeclarationStatement x) { visit(cast(Statement)x); }
    override void visit(ExpressionStatement x) { visit(cast(Statement)x); }
    override void visit(IfElseStatement x) { visit(cast(Statement)x); }
    override void visit(WhileStatement x) { visit(cast(Statement)x); }
    override void visit(DoWhileStatement x) { visit(cast(Statement)x); }
    override void visit(ForStatement x) { visit(cast(Statement)x); }
    override void visit(ForeachStatement x) { visit(cast(Statement)x); }
    override void visit(ForeachReverseStatement x) { visit(cast(Statement)x); }
    override void visit(BreakStatement x) { visit(cast(Statement)x); }
    override void visit(ContinueStatement x) { visit(cast(Statement)x); }
    override void visit(GotoStatement x) { visit(cast(Statement)x); }
    override void visit(ReturnStatement x) { visit(cast(Statement)x); }
    override void visit(LabelStatement x) { visit(cast(Statement)x); }
    override void visit(BlockStatement x) { visit(cast(Statement)x); }
    override void visit(MixinStatement x) { visit(cast(Statement)x); }

	/* struct_.d */
	override void visit(StructDeclaration x) { visit(cast(AggregateDeclaration)x); }

	/* symbol.d */
	override void visit(Symbol x) { visit(cast(ASTNode)x); }
	override void visit(ScopeSymbol x) { visit(cast(Symbol)x); }

    /* template_.d */
    override void visit(TemplateInstance) {}
	override void visit(TemplateDeclaration) {}

    /* type.d */
    override void visit(Type x) { visit(cast(ASTNode)x); }
    override void visit(ErrorType x) { visit(cast(Type)x); }
    override void visit(BuiltInType x) { visit(cast(Type)x); }
    override void visit(FuncType x) { visit(cast(Type)x); }
    override void visit(LazyType x) { visit(cast(Type)x); }
    override void visit(PtrType x) { visit(cast(Type)x); }
    override void visit(ArrayType x) { visit(cast(Type)x); }
    override void visit(AArrayType x) { visit(cast(Type)x); }
    override void visit(TupleType x) { visit(cast(Type)x); }
	override void visit(SymbolType x) { visit(cast(Type)x); }
	override void visit(IdentifierType x) { visit(cast(SymbolType)x); }
    override void visit(InstanceType x) { visit(cast(SymbolType)x); }
	override void visit(StructType x) { visit(cast(Type) x); }

	/* typeid_.d */
    override void visit(Typeid x) { visit(cast(ASTNode)x); }
}