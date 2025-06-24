*** Settings ***
Library    Browser
Library    DateTime
Library    RequestsLibrary
Suite Setup    Initialize Browser
Suite Teardown    Close Browser
Resource    ../../resource/keywords.robot
Variables    ../../resource/environment_variables.py
Library    Collections
Library    JSONLibrary
Library    WebsocketClient

*** Keywords ***
Initialize Browser
    #New Browser    chromium    headless=${check_visible}
    New Browser    chromium    headless=False
    New Context    viewport={'width': 1600, 'height': 900}    acceptDownloads=True
    New Page    http://192.168.11.180    load
    #Log    Testing version ${VERSION} in ${environment} environment

Continuous page
    New Browser    chromium    headless=True    slowMo=1
    New Page    ${main_url}

*** Variables ***
#&{header}    Content-Type=application/json
#&{headers}    Content-Type=application/json    Authorization=${token}
#&{newpage_payload}    parent=00000000-0000-0000-0000-000000000000    oid1=menu99    oid2=robot_page    oid3=nav_ic_bulletin    oi4=[]    oid5=00000000-0000-0000-0000-000000000000    groudid=00000000-0000-0000-0000-000000000000
#&{newtag_body}    parent=${page_id}    oid1=menu99999999    oid2=robot_tag    oid5=00000000-0000-0000-0000-000000000000    groudid=00000000-0000-0000-0000-000000000000
${url}    http://192.168.11.180/
*** Test Cases ***
登入
    # New Page    http://192.168.11.22    load
    Fill Text    id=account    admin
    Fill Text    id=password    P@ssw0rd
    Click    id=loginBtn
    Wait For Load State    load    30
    Wait For Elements State    .wrapper    visible    15s
    ${current_url}=    Get Url
    ${token_start}    Get Regexp Matches    ${current_url}    token=([a-zA-Z0-9]+)    1
    ${extracted_token}    Set Variable    ${token_start}[0]
    Log    ${extracted_token}
    Set Global Variable    ${main_url}    ${current_url}
    Set Global Variable    ${token}    ${extracted_token}

    ${headers}    Create Dictionary    Content-Type=application/json    Authorization=${token}
