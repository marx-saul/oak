module sem.expr;

import ast;
import sem.symbol;
import sem.scope_;

void sem_expr(Expr* expr, Scope scp, ref bool flag) {
}

void type_inferrence(Expr* expr, Scope scp, ref bool flag) {
	if (!expr || !scp) return;
	if (expr.type) return;
	
	bool result;
	
	if (auto e = (*expr).isBinExpr) {
		// infer the type of sub-expressions
		type_inferrence(&e.expr0, scp, flag);
		type_inferrence(&e.expr1, scp, flag);
		
		// if the type semantics are done
		if (!e.expr0.type || !e.expr1.type) return;
		if (!e.expr0.type.sem_ok || !e.expr1.type.sem_ok) return;
		
		if (e.expr0.type.isNumType() && e.expr1.type.isNumType()) {
			expr.type = to_common_num_type(e.expr0.type, e.expr1.type);
			flag = true;
		}
		else {
			import token;
			// TODO: generate a more specific error message
			(*expr).type = new ErrorType("Cannot " ~ e.op.toString() ~ " non-numerical types.");
			flag = true;
		}
	}
	
}
