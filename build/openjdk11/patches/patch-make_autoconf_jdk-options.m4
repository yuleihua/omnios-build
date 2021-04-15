$NetBSD$

Shell portability.

--- make/autoconf/jdk-options.m4.orig	2019-01-08 09:40:28.000000000 +0000
+++ make/autoconf/jdk-options.m4
@@ -207,7 +207,7 @@ AC_DEFUN_ONCE([JDKOPT_SETUP_JDK_OPTIONS]
   AC_ARG_WITH(cacerts-file, [AS_HELP_STRING([--with-cacerts-file],
       [specify alternative cacerts file])])
   AC_MSG_CHECKING([for cacerts file])
-  if test "x$with_cacerts_file" == x; then
+  if test "x$with_cacerts_file" = x; then
     AC_MSG_RESULT([default])
   else
     CACERTS_FILE=$with_cacerts_file
