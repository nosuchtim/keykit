True=1
False=0

function test_logical()
{
        if (True) {
		print("test_logical: pass1");
	}
	else {
		print("test_logical: fail1");
		return (False);
	}

        if (False) {
		print("test_logical: fail2");
		return (False);
	}
	else {
		print("test_logical: pass2");
	}
	return (True);
}

function test_logical_not()
{
        if (!True) {
		print("test_logical_not: fail1");
		return (False);
	}
	else {
		print("test_logical_not: pass1");
	}

        if (!False) {
		print("test_logical_not: pass2");
	}
	else {
		print("test_logical_not: fail2");
		return (False);
	}
	return (True);
}
	
function test_logical_bin_or()
{
        if (False || False) {
		print("test_logical_bin_or: fail1");
		return (False);
	}
	else {
		print("test_logical_bin_or: pass1");
	}

        if (True || False) {
		print("test_logical_bin_or: pass2");
	}
	else {
		print("test_logical_bin_or: fail2");
		return (False);
	}

        if (False || True) {
		print("test_logical_bin_or: pass3");
	}
	else {
		print("test_logical_bin_or: fail3");
		return (False);
	}

        if (True || True) {
		print("test_logical_bin_or: pass4");
	}
	else {
		print("test_logical_bin_or: fail4");
		return (False);
	}
	
	return (True);
}

function test_logical_value_bin_or()
{
	e = False || False;
        if (e) {
		print("test_logical_value_bin_or: fail1");
		return (False);
	}
	else {
		print("test_logical_value_bin_or: pass1");
	}

	e = True || False;
        if (e) {
		print("test_logical_value_bin_or: pass2");
	}
	else {
		print("test_logical_value_bin_or: fail2");
		return (False);
	}

	e = False || True;
        if (e) {
		print("test_logical_value_bin_or: pass3");
	}
	else {
		print("test_logical_value_bin_or: fail3");
		return (False);
	}

	e = True || True;
        if (e) {
		print("test_logical_value_bin_or: pass4");
	}
	else {
		print("test_logical_value_bin_or: fail4");
		return (False);
	}
	
	return (True);
}

function test_logical_bin_and()
{
        if (False && False) {
		print("test_logical_bin_and: fail1");
		return (False);
	}
	else {
		print("test_logical_bin_and: pass1");
	}

        if (True && False) {
		print("test_logical_bin_and: fail2");
		return (False);
	}
	else {
		print("test_logical_bin_and: pass2");
	}

        if (False && True) {
		print("test_logical_bin_and: fail3");
		return (False);
	}
	else {
		print("test_logical_bin_and: pass3");
	}

        if (True && True) {
		print("test_logical_bin_and: pass4");
	}
	else {
		print("test_logical_bin_and: fail4");
		return (False);
	}
	
	return (True);
}

function test_logical_value_bin_and()
{
	e = False && False;
        if (e) {
		print("test_logical_value_bin_and: fail1");
		return (False);
	}
	else {
		print("test_logical_value_bin_and: pass1");
	}

	e = True && False;
        if (e) {
		print("test_logical_value_bin_and: fail2");
		return (False);
	}
	else {
		print("test_logical_value_bin_and: pass2");
	}

	e = False && True;
        if (e) {
		print("test_logical_value_bin_and: fail3");
		return (False);
	}
	else {
		print("test_logical_value_bin_and: pass3");
	}

	e = True && True;
        if (e) {
		print("test_logical_value_bin_and: pass4");
	}
	else {
		print("test_logical_value_bin_and: fail4");
		return (False);
	}
	
	return (True);
}

function test_logical_tri_or()
{
        if (False || (False || False) ) {
		print("test_logical_tri_or: fail1");
		return (False);
	}
	else {
		print("test_logical_tri_or: pass1");
	}

        if (False || (False || True) ) {
		print("test_logical_tri_or: pass2");
	}
	else {
		print("test_logical_tri_or: fail2");
		return (False);
	}

        if (False || (True || False) ) {
		print("test_logical_tri_or: pass3");
	}
	else {
		print("test_logical_tri_or: fail3");
		return (False);
	}

        if (False || (True || True) ) {
		print("test_logical_tri_or: pass4");
	}
	else {
		print("test_logical_tri_or: fail4");
		return (False);
	}

        if (True || (False || False) ) {
		print("test_logical_tri_or: pass5");
	}
	else {
		print("test_logical_tri_or: fail5");
		return (False);
	}

        if (True || (False || True) ) {
		print("test_logical_tri_or: pass6");
	}
	else {
		print("test_logical_tri_or: fail6");
		return (False);
	}

        if (True || (True || False) ) {
		print("test_logical_tri_or: pass7");
	}
	else {
		print("test_logical_tri_or: fail7");
		return (False);
	}

        if (True || (True || True) ) {
		print("test_logical_tri_or: pass8");
	}
	else {
		print("test_logical_tri_or: fail8");
		return (False);
	}

	return (True);
}

function test_logical_tri_and_1()
{
        if (False && (False && False) ) {
		print("test_logical_tri_and_1: fail1");
		return (False);
	}
	else {
		print("test_logical_tri_and_1: pass1");
	}

        if (False && (False && True) ) {
		print("test_logical_tri_and_1: fail2");
		return (False);
	}
	else {
		print("test_logical_tri_and_1: pass2");
	}

        if (False && (True && False) ) {
		print("test_logical_tri_and_1: fail3");
		return (False);
	}
	else {
		print("test_logical_tri_and_1: pass3");
	}

        if (False && (True && True) ) {
		print("test_logical_tri_and_1: fail4");
		return (False);
	}
	else {
		print("test_logical_tri_and_1: pass4");
	}

        if (True && (False && False) ) {
		print("test_logical_tri_and_1: fail5");
		return (False);
	}
	else {
		print("test_logical_tri_and_1: pass5");
	}

        if (True && (False && True) ) {
		print("test_logical_tri_and_1: fail6");
		return (False);
	}
	else {
		print("test_logical_tri_and_1: pass6");
	}

        if (True && (True && False) ) {
		print("test_logical_tri_and_1: fail7");
		return (False);
	}
	else {
		print("test_logical_tri_and_1: pass7");
	}

        if (True && (True && True) ) {
		print("test_logical_tri_and_1: pass8");
	}
	else {
		print("test_logical_tri_and_1: fail8");
		return (False);
	}

	return (True);
}

function test_logical_tri_and_2()
{
        if ( (False && False) && False ) {
		print("test_logical_tri_and_2: fail1");
		return (False);
	}
	else {
		print("test_logical_tri_and_2: pass1");
	}

	if ( (False && False) && True ) {
		print("test_logical_tri_and_2: fail2");
		return (False);
	}
	else {
		print("test_logical_tri_and_2: pass2");
	}

        if ( (False && True) && False ) {
		print("test_logical_tri_and_2: fail3");
		return (False);
	}
	else {
		print("test_logical_tri_and_2: pass3");
	}

        if ( (False && True) && True ) {
		print("test_logical_tri_and_2: fail4");
		return (False);
	}
	else {
		print("test_logical_tri_and_2: pass4");
	}

        if ( (True && False) && False ) {
		print("test_logical_tri_and_2: fail5");
		return (False);
	}
	else {
		print("test_logical_tri_and_2: pass5");
	}

        if ( (True && False) && True ) {
		print("test_logical_tri_and_2: fail6");
		return (False);
	}
	else {
		print("test_logical_tri_and_2: pass6");
	}

        if ( (True && True) && False ) {
		print("test_logical_tri_and_2: fail7");
		return (False);
	}
	else {
		print("test_logical_tri_and_2: pass7");
	}

        if ( (True && True) && True ) {
		print("test_logical_tri_and_2: pass8");
	}
	else {
		print("test_logical_tri_and_2: fail8");
		return (False);
	}

	return (True);
}

function test_logical_bin_not_or()
{
        if ( !(False || False) ) {
		print("test_logical_bin_not_or: pass1");
	}
	else {
		print("test_logical_bin_not_or: fail1");
		return (False);
	}

        if ( !(True || False) ) {
		print("test_logical_bin_not_or: fail2");
		return (False);
	}
	else {
		print("test_logical_bin_not_or: pass2");
	}

        if ( !(False || True) ) {
		print("test_logical_bin_not_or: fail3");
		return (False);
	}
	else {
		print("test_logical_bin_not_or: pass3");
	}

        if ( !(True || True) ) {
		print("test_logical_bin_not_or: fail4");
		return (False);
	}
	else {
		print("test_logical_bin_not_or: pass4");
	}
	
	return (True);
}

function test_logical_value_bin_not_or()
{
	e = !(False || False);
        if (e) {
		print("test_logical_value_bin_not_or: pass1");
	}
	else {
		print("test_logical_value_bin_not_or: fail1");
		return (False);
	}

	e = !(True || False);
        if (e) {
		print("test_logical_value_bin_not_or: fail2");
		return (False);
	}
	else {
		print("test_logical_value_bin_not_or: pass2");
	}

	e = !(False || True);
        if (e) {
		print("test_logical_value_bin_not_or: fail3");
		return (False);
	}
	else {
		print("test_logical_value_bin_not_or: pass3");
	}

	e = !(True || True);
        if (e) {
		print("test_logical_value_bin_not_or: fail4");
		return (False);
	}
	else {
		print("test_logical_value_bin_not_or: pass4");
	}
	
	return (True);
}

function test_logical_bin_not_and()
{
        if ( !(False && False) ) {
		print("test_logical_bin_not_and: pass1");
	}
	else {
		print("test_logical_bin_not_and: fail1");
		return (False);
	}

        if ( !(True && False) ) {
		print("test_logical_bin_not_and: pass2");
	}
	else {
		print("test_logical_bin_not_and: fail2");
		return (False);
	}

        if ( !(False && True) ) {
		print("test_logical_bin_not_and: pass3");
	}
	else {
		print("test_logical_bin_not_and: fail3");
		return (False);
	}

        if ( !(True && True) ) {
		print("test_logical_bin_not_and: fail4");
		return (False);
	}
	else {
		print("test_logical_bin_not_and: pass4");
	}
	
	return (True);
}

function test_logical_value_bin_not_and()
{
	e = !(False && False);
        if (e) {
		print("test_logical_value_bin_not_and: pass1");
	}
	else {
		print("test_logical_value_bin_not_and: fail1");
		return (False);
	}

	e = !(True && False);
        if (e) {
		print("test_logical_value_bin_not_and: pass2");
	}
	else {
		print("test_logical_value_bin_not_and: fail2");
		return (False);
	}

	e = !(False && True);
        if (e) {
		print("test_logical_value_bin_not_and: pass3");
	}
	else {
		print("test_logical_value_bin_not_and: fail3");
		return (False);
	}

	e = !(True && True);
        if (e) {
		print("test_logical_value_bin_not_and: fail4");
		return (False);
	}
	else {
		print("test_logical_value_bin_not_and: pass4");
	}
	
	return (True);
}

function test_logical_bin_or_not_1()
{
        if (False || !False) {
		print("test_logical_bin_or_not_1: pass1");
	}
	else {
		print("test_logical_bin_or_not_1: pass1");
		return (False);
	}

        if (True || !False) {
		print("test_logical_bin_or_not_1: pass2");
	}
	else {
		print("test_logical_bin_or_not_1: pass2");
		return (False);
	}

        if (False || !True) {
		print("test_logical_bin_or_not_1: pass3");
		return (False);
	}
	else {
		print("test_logical_bin_or_not_1: pass3");
	}

        if (True || !True) {
		print("test_logical_bin_or_not_1: pass4");
	}
	else {
		print("test_logical_bin_or_not_1: pass4");
		return (False);
	}
	
	return (True);
}

function test_logical_value_bin_or_not_1()
{
	e = False || !False;
        if (e) {
		print("test_logical_value_bin_or_not_1: pass1");
	}
	else {
		print("test_logical_value_bin_or_not_1: pass1");
		return (False);
	}

	e = True || !False;
        if (e) {
		print("test_logical_value_bin_or_not_1: pass2");
	}
	else {
		print("test_logical_value_bin_or_not_1: pass2");
		return (False);
	}

	e = False || !True;
        if (e) {
		print("test_logical_value_bin_or_not_1: pass3");
		return (False);
	}
	else {
		print("test_logical_value_bin_or_not_1: pass3");
	}

	e = True || !True;
        if (e) {
		print("test_logical_value_bin_or_not_1: pass4");
	}
	else {
		print("test_logical_value_bin_or_not_1: pass4");
		return (False);
	}
	
	return (True);
}

function test_logical_bin_or_not_2()
{
        if (!False || False) {
		print("test_logical_bin_or_not_2: pass1");
	}
	else {
		print("test_logical_bin_or_not_2: fail1");
		return (False);
	}

        if (!True || False) {
		print("test_logical_bin_or_not_2: fail2");
		return (False);
	}
	else {
		print("test_logical_bin_or_not_2: pass2");
	}

        if (!False || True) {
		print("test_logical_bin_or_not_2: pass3");
	}
	else {
		print("test_logical_bin_or_not_2: fail3");
		return (False);
	}

        if (!True || True) {
		print("test_logical_bin_or_not_2: pass4");
	}
	else {
		print("test_logical_bin_or_not_2: fail4");
		return (False);
	}
	
	return (True);
}

function test_logical_value_bin_or_not_2()
{
	e = !False || False;
        if (e) {
		print("test_logical_value_bin_or_not_2: pass1");
	}
	else {
		print("test_logical_value_bin_or_not_2: fail1");
		return (False);
	}

	e = !True || False;
        if (e) {
		print("test_logical_value_bin_or_not_2: fail2");
		return (False);
	}
	else {
		print("test_logical_value_bin_or_not_2: pass2");
	}

	e = !False || True;
        if (e) {
		print("test_logical_value_bin_or_not_2: pass3");
	}
	else {
		print("test_logical_value_bin_or_not_2: fail3");
		return (False);
	}

	e = !True || True;
        if (e) {
		print("test_logical_value_bin_or_not_2: pass4");
	}
	else {
		print("test_logical_value_bin_or_not_2: fail4");
		return (False);
	}
	
	return (True);
}

function test_logical_bin_and_not_1()
{
        if (False && !False) {
		print("test_logical_bin_and_not_1: pass1");
		return (False);
	}
	else {
		print("test_logical_bin_and_not_1: pass1");
	}

        if (True && !False) {
		print("test_logical_bin_and_not_1: pass2");
	}
	else {
		print("test_logical_bin_and_not_1: pass2");
		return (False);
	}

        if (False && !True) {
		print("test_logical_bin_and_not_1: pass3");
		return (False);
	}
	else {
		print("test_logical_bin_and_not_1: pass3");
	}

        if (True && !True) {
		print("test_logical_bin_and_not_1: pass4");
		return (False);
	}
	else {
		print("test_logical_bin_and_not_1: pass4");
	}
	
	return (True);
}

function test_logical_value_bin_and_not_1()
{
	e = False && !False;
        if (e) {
		print("test_logical_value_bin_and_not_1: pass1");
		return (False);
	}
	else {
		print("test_logical_value_bin_and_not_1: pass1");
	}

	e = True && !False;
        if (e) {
		print("test_logical_value_bin_and_not_1: pass2");
	}
	else {
		print("test_logical_value_bin_and_not_1: pass2");
		return (False);
	}

	e = False && !True;
        if (e) {
		print("test_logical_value_bin_and_not_1: pass3");
		return (False);
	}
	else {
		print("test_logical_value_bin_and_not_1: pass3");
	}

	e = True && !True;
        if (e) {
		print("test_logical_value_bin_and_not_1: pass4");
		return (False);
	}
	else {
		print("test_logical_value_bin_and_not_1: pass4");
	}
	
	return (True);
}

function test_logical_bin_and_not_2()
{
        if (!False && False) {
		print("test_logical_bin_and_not_2: fail1");
		return (False);
	}
	else {
		print("test_logical_bin_and_not_2: pass1");
	}

        if (!True && False) {
		print("test_logical_bin_and_not_2: fail2");
		return (False);
	}
	else {
		print("test_logical_bin_and_not_2: pass2");
	}

        if (!False && True) {
		print("test_logical_bin_and_not_2: pass3");
	}
	else {
		print("test_logical_bin_and_not_2: fail3");
		return (False);
	}

        if (!True && True) {
		print("test_logical_bin_and_not_2: fail4");
		return (False);
	}
	else {
		print("test_logical_bin_and_not_2: pass4");
	}
	
	return (True);
}

function test_logical_value_bin_and_not_2()
{
	e = !False && False;
        if (e) {
		print("test_logical_value_bin_and_not_2: fail1");
		return (False);
	}
	else {
		print("test_logical_value_bin_and_not_2: pass1");
	}

	e = !True && False;
        if (e) {
		print("test_logical_value_bin_and_not_2: fail2");
		return (False);
	}
	else {
		print("test_logical_value_bin_and_not_2: pass2");
	}

	e = !False && True;
        if (e) {
		print("test_logical_value_bin_and_not_2: pass3");
	}
	else {
		print("test_logical_value_bin_and_not_2: fail3");
		return (False);
	}

	e = !True && True;
	if (e) {
		print("test_logical_value_bin_and_not_2: fail4");
		return (False);
	}
	else {
		print("test_logical_value_bin_and_not_2: pass4");
	}
	
	return (True);
}

function test_logical_expr()
{
        test_logical()
        test_logical_not()
        test_logical_bin_or()
        test_logical_bin_and()
        test_logical_tri_or()
        test_logical_tri_and_1()
        test_logical_tri_and_2()
        test_logical_bin_or_not_1()
        test_logical_bin_or_not_2()
	test_logical_bin_not_or()
        test_logical_bin_and_not_1()
        test_logical_bin_and_not_2()
	test_logical_bin_not_and()
	test_logical_value_bin_or()
	test_logical_value_bin_and()
	test_logical_value_bin_or_not_1()
	test_logical_value_bin_or_not_2()
	test_logical_value_bin_and_not_1()
	test_logical_value_bin_and_not_2()
	test_logical_value_bin_not_or()
	test_logical_value_bin_not_and()
#        test_logical_and()
#        test_logical_not()
#        test_logical_not_and()
#        test logical_and_not()
#        test_logical_not_or()
#        test_logical_or_not()
}

test_logical_expr();


