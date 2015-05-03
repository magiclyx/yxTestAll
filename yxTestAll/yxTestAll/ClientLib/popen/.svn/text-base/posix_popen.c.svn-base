//
//  test.c
//  testSystemReport
//
//  Created by Yuxi Liu on 10/30/12.
//  Copyright (c) 2012 Yuxi Liu. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include <unistd.h>
#include <pthread.h>
#include <errno.h>
#include <limits.h>


#include "../cm/cmMem.h"
#include "../popen/posix_popen.h"




#ifdef  OPEN_MAX
static long openmax = OPEN_MAX;
#else
static long openmax = 0;
#endif

/*
 * If OPEN_MAX is indeterminate, we're not
 * guaranteed that this is adequate.
 */
#define OPEN_MAX_GUESS 256

static long _open_max(void);



typedef struct {
    pid_t* childpid;  //child process id
    int fd; //piple id
}_popen_context_, *_popen_context_ref;






HPOPOPEN posix_popen(const char *cmdstring, const char *type){
    int     i;
    int     pfd[2];
    pid_t   pid;
    int maxfd;
    
    _popen_context_ref context = NULL;
    
    //alloc the context handle
    if(NULL == (context = (_popen_context_ref)MALLOC(sizeof(_popen_context_))))
        goto errout;
    
    //alloc the child pid buffer
    maxfd = (int)_open_max();
    if(NULL == (context->childpid = (pid_t*)CALLOC(maxfd, sizeof(pid_t))))
        goto errout;
    
    
    /* only allow "r" or "w" */
    if ((type[0] != 'r' && type[0] != 'w') || type[1] != 0) {
        errno = EINVAL;     /* required by POSIX */
        goto errout;
    }
    
    
    /*init the pip*/
    if (pipe(pfd) < 0)
        goto errout;   /* errno set by pipe() */
    
    
    
    
    if ((pid = fork()) < 0) {
        goto errout; //erno set by fork();
    } else if (pid == 0) {                           /* child */
        if (*type == 'r') {
            close(pfd[0]);
            if (pfd[1] != STDOUT_FILENO) {
                dup2(pfd[1], STDOUT_FILENO);
                close(pfd[1]);
            }
        } else {
            close(pfd[1]);
            if (pfd[0] != STDIN_FILENO) {
                dup2(pfd[0], STDIN_FILENO);
                close(pfd[0]);
            }
        }
        
        /* close all descriptors in childpid[] */
        for (i = 0; i < maxfd; i++)
            if (context->childpid[i] > 0)
                close(i);
        
        execl("/bin/sh", "sh", "-c", cmdstring, (char *)0);
        _exit(127);
    }
    
    
    
    /* parent continues... */
    if(*type == 'r'){
        close(pfd[1]);
        context->fd = pfd[0];
    }
    else{
        close(pfd[0]);
        context->fd = pfd[1];
    }
    
    context->childpid[context->fd] = pid;
    

    return (HPOPOPEN)context;
    
errout:
    
    if(NULL != context){
        
        if(NULL != context->childpid)
            FREE(context->childpid);
        
        FREE(context);
    }
    

    return NULL;
}


//return child's termination status
int posix_pclose(HPOPOPEN* handleRef)

{
    
    int stat;
    pid_t   pid;
    _popen_context_ref context = (_popen_context_ref)(*handleRef);
    *handleRef = NULL;
    
    if(NULL == context){
        errno = EINVAL;
        goto errout;
    }
    
    if(NULL == context->childpid){
        errno = EINVAL;
        goto errout;
    }
     
    
    if ((pid = context->childpid[context->fd]) == 0) {
        errno = EINVAL;
        goto errout;     /* fp wasn't opened by popen() */
    }
    
    
    context->childpid[context->fd] = 0;
    if(0 != close(context->fd)){
        errno = EINVAL;
        goto errout;
    }
    
    
    while (waitpid(pid, &stat, 0) < 0)
        if (errno != EINTR)
            goto errout; /* error other than EINTR from waitpid() */
    
    
    FREE(context->childpid);
    FREE(context);
    
    
    
    return(stat);   /* return child's termination status */
    
errout:
    
    if(NULL != context){
        
        if(NULL != context->childpid)
            FREE(context->childpid);
        
        FREE(context);
    }
    
    return -1;
    
}



int posix_pwrite(HPOPOPEN handle, const void *buf, size_t bufSize, size_t *bytesWritten){
    int 	err;
	char *	cursor;
	size_t	bytesLeft;
	ssize_t bytesThisTime;
    int fd;
	
    // Pre-conditions
    
    _popen_context_ref context = (_popen_context_ref)(handle);
    if(NULL == handle)
        return -1;
    fd = context->fd;
    
    
    
	assert(fd >= 0);
	assert(buf != NULL);
    // bufSize may be 0
	// bytesWritten may be NULL
    // bufSize may be 0
	// bytesWritten may be NULL
	
	// SIGPIPE occurs when you write to pipe or socket
	// whose other end has been closed.  The default action
	// for SIGPIPE is to terminate the process.  That's
	// probably not what you wanted.  So, in the debug build,
	// we check that you've set the signal action to SIG_IGN
	// (ignore).  Of course, you could be building a program
	// that needs SIGPIPE to work in some special way, in
	// which case you should define BAS_WRITE_CHECK_SIGPIPE
	// to 0 to bypass this check.
	
#if SL_DEBUG
    {
        int					junk;
        struct stat			sb;
        struct sigaction	currentSignalState;
        int					val;
        socklen_t			valLen;
        
        junk = fstat(fd, &sb);
        assert(junk == 0);
        
        if ( /*S_ISFIFO(sb.st_mode) ||*/ S_ISSOCK(sb.st_mode) ) {
            junk = sigaction(SIGPIPE, NULL, &currentSignalState);
            assert(junk == 0);
            
            valLen = sizeof(val);
            junk = getsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &val, &valLen);
            assert(junk == 0);
            assert(valLen == sizeof(val));
            
            // If you hit this assertion, you need to either disable SIGPIPE in
            // your process or on the specific socket you're writing to.  The
            // standard code for the former is:
            //
            // (void) signal(SIGPIPE, SIG_IGN);
            //
            // You typically add this code to your main function.
            //
            // The standard code for the latter is:
            //
            // static const int kOne = 1;
            // err = setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &kOne, sizeof(kOne));
            //
            // You typically do this just after creating the socket.
            
            assert( (currentSignalState.sa_handler == SIG_IGN) || (val == 1) );
        }
    }
#endif //SL_DEBUG
    
    
    
	err = 0;
	bytesLeft = bufSize;
	cursor = (char *) buf;
	while ( (err == 0) && (bytesLeft != 0) ) {
		bytesThisTime = write(fd, cursor, bytesLeft);
		if (bytesThisTime > 0) {
			cursor    += bytesThisTime;
			bytesLeft -= bytesThisTime;
		} else if (bytesThisTime == 0) {
			assert(0);
			err = EPIPE;
		} else {
			assert(bytesThisTime == -1);
			
			err = errno;
			assert(err != 0);
			if (err == EINTR) {
				err = 0;		// let's loop again
			}
		}
	}
	if (bytesWritten != NULL) {
		*bytesWritten = bufSize - bytesLeft;
	}
	
	return err;
}



int posix_pread(HPOPOPEN handle, void *buf, size_t bufSize, size_t *bytesRead)
// A wrapper around <x-man-page://2/read> that keeps reading until either
// bufSize bytes are read or until EOF is encountered, in which case you get
// EPIPE.
//
// If bytesRead is not NULL, *bytesRead will be set to the number
// of bytes successfully read.  On success, this will always be equal to
// bufSize.  On error, it indicates how much was read before the error
// occurred (which could be zero).
{
	int 	err;
	char *	cursor;
	size_t	bytesLeft;
	ssize_t bytesThisTime;
    int fd;
	
    // Pre-conditions
    
    _popen_context_ref context = (_popen_context_ref)(handle);
    if(NULL == handle)
        return -1;
    fd = context->fd;
    
    
    
	assert(fd >= 0);
	assert(buf != NULL);
    // bufSize may be 0
    // bytesRead may be NULL
	
    // char* charBuff = malloc(bufSize*sizeof(char));
    
	err = 0;
	bytesLeft = bufSize;
	cursor = (char *) buf;
	while ( (err == 0) && (bytesLeft != 0) ) {
		bytesThisTime = read(fd, cursor, bytesLeft);
		if (bytesThisTime > 0) {
			cursor    += bytesThisTime;
			bytesLeft -= bytesThisTime;
		} else if (bytesThisTime == 0) {
			err = EPIPE;
		} else {
			assert(bytesThisTime == -1);
			
			err = errno;
			assert(err != 0);
			if (err == EINTR) {
				err = 0;		// let's loop again
			}
		}
	}
	if (bytesRead != NULL) {
		*bytesRead = bufSize - bytesLeft;
	}
    
	
	return err;
}




static long _open_max(void)
{
    if (openmax == 0) {      /* first time through */
        errno = 0;
        if ((openmax = sysconf(_SC_OPEN_MAX)) < 0) {
            if (errno == 0)
                openmax = OPEN_MAX_GUESS;    /* it's indeterminate */
            else
                printf("sysconf error for _SC_OPEN_MAX");
        }
    }
    
    return(openmax);
}




