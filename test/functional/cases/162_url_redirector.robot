*** Settings ***
Suite Setup     Urlredirector Setup
Suite Teardown  Urlredirector Teardown
Library         Process
Library         ${TESTDIR}/lib/rspamd.py
Resource        ${TESTDIR}/lib/rspamd.robot
Variables       ${TESTDIR}/lib/vars.py

*** Variables ***
${CONFIG}       ${TESTDIR}/configs/url_redirector.conf
${MESSAGE}      ${TESTDIR}/messages/redir.eml
${REDIS_SCOPE}  Suite
${RSPAMD_SCOPE}  Suite
${SETTINGS}     {symbols_enabled=[URL_REDIRECTOR_CHECK]}
${URL_TLD}      ${TESTDIR}/../../contrib/publicsuffix/effective_tld_names.dat

*** Test Cases ***
RESOLVE URLS
  Scan File  ${MESSAGE}  Flags=ext_urls  Settings=${SETTINGS}
  Expect Extended URL  http://127.0.0.1:18080/hello

RESOLVE URLS CACHED
  Stop Dummy Http
  Scan File  ${MESSAGE}  Flags=ext_urls  Settings=${SETTINGS}
  Expect Extended URL  http://127.0.0.1:18080/hello

*** Keywords ***
Urlredirector Setup
  ${TMPDIR} =    Make Temporary Directory
  Set Suite Variable        ${TMPDIR}
  Set Suite Variable  ${REDIS_TMPDIR}  ${TMPDIR}
  Run Redis
  Run Dummy Http
  New Setup  URL_TLD=${URL_TLD}

Urlredirector Teardown
  Normal Teardown
  #Stop Dummy Http
  Terminate All Processes    kill=True

Stop Dummy Http
  ${http_pid} =  Get File  /tmp/dummy_http.pid
  Shutdown Process With Children  ${http_pid}

Run Dummy Http
  ${result} =  Start Process  ${TESTDIR}/util/dummy_http.py
  Wait Until Created  /tmp/dummy_http.pid
