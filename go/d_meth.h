void o_setinit(int argc);
#ifdef OLDSTUFF
#endif
void setelement(Kobjectp o,Symstr e,Datum d);
void setmethod(Kobjectp o,char *m,BLTINCODE i);
void setdata(Kobjectp o,char *m,Datum d);
Kobjectp defaultobject(long id,int complain);
void o_addchild(int argc);
#ifdef SAVEFORERRORCHECKING
void chksib(Kobjectp o1, char *s);
#endif
void o_removechild(int argc);
void o_children(int argc);
void o_addinherit(int argc);
void o_inherited(int argc);
Kwind* windid(Kobjectp o);
void o_size(int argc);
void o_contains(int argc);
void o_mousedo(int argc);
int needplotmode(char *meth,Datum d);
void o_lineboxfill(int argc,char *meth,KWFUNC f,int norm);
void o_fillpolygon(int argc);
void o_line(int argc);
void o_box(int argc);
void o_fill(int argc);
void o_ellipse(int argc);
void o_fillellipse(int argc);
void o_style(int argc);
void o_saveunder(int argc);
void o_restoreunder(int argc);
void o_textheight(int argc);
void o_textwidth(int argc);
void o_text(int argc,int just);
void o_printf(int argc);
void o_textcenter(int argc);
void o_textleft(int argc);
void o_textright(int argc);
void o_type(int argc);
void o_xmin(int argc);
void o_ymin(int argc);
void o_xmax(int argc);
void o_ymax(int argc);
void o_redraw(int argc);
void o_childunder(int argc);
void o_drawphrase(int argc);
void o_scaletogrid(int argc);
void o_scaletowind(int argc);
void o_closestnote(int argc);
void o_view(int argc);
void o_sweep(int argc);
void o_trackname(int argc);
void o_menuitem(int argc);
void o_menuitems(int argc);
Kobjectp windobject(long id,int complain,char *type);
#ifdef OLDSTUFF
#endif
