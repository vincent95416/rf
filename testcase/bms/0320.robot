*** Settings ***
Library    Browser
Library    DateTime
Library    RequestsLibrary
Suite Setup    Initialize Browser
Suite Teardown    Close Browser
Resource    ../../resource/keywords.robot
Variables    ../../resource/environment_variables.py

*** Keywords ***
Initialize Browser
    #New Browser    chromium    headless=${check_visible}
    New Browser    chromium    headless=False
    New Context    viewport={'width': 1600, 'height': 900}    acceptDownloads=True
    New Page    http://192.168.11.22    load
    #Log    Testing version ${VERSION} in ${environment} environment

Continuous page
    New Browser    chromium    headless=True    slowMo=1
    New Page    ${main_url}

*** Variables ***
&{header}    Content-Type=application/json    
&{payload}    acc=admin    pwd=P@ssw0rd
&{newpage_body}    parent=00000000-0000-0000-0000-000000000000    oid1=menu99    oid2=robot_page    oid3=nav_ic_bulletin    oi4=[]    oid5=00000000-0000-0000-0000-000000000000    groudid=00000000-0000-0000-0000-000000000000
#&{newtag_body}    parent=${page_id}    oid1=menu99999999    oid2=robot_tag    oid5=00000000-0000-0000-0000-000000000000    groudid=00000000-0000-0000-0000-000000000000

*** Test Cases ***
登入
    #New Page    http://192.168.11.22    load
    Fill Text    id=account    admin
    Fill Text    id=password    P@ssw0rd
    Click    id=loginBtn
    Wait For Load State    load    30
    Wait For Elements State    css=body    visible    15s
    Wait For Elements State    .wrapper    visible    30s
    ${current_url}=    Get Url
    ${key_token}    Session Storage Get Item    token
    Set Global Variable    ${main_url}    ${current_url}
    Set Global Variable    ${token}    ${key_token}

0324
    ${page_response}    POST    url=http://192.168.11.26/TreeData/treedata/?token=${token}    headers=&{header}    json=&{newpage_body}    expected_status=200
    ${page_data}    Set Variable    ${page_response.json()}[data]
    Log    ${page_data}
    ${page_id}    Set Variable    ${page_data}[id]
    &{newtag_body}    Create Dictionary    parent=${page_id}    oid1=page99    oid2=robot_tag    oid4=00000000-0000-0000-0000-000000000000    oid5=100    groudid=00000000-0000-0000-0000-000000000000
    ${tag_response}    POST    url=http://192.168.11.26/TreeData/treedata/?token=${token}    headers=&{header}    json=&{newtag_body}    expected_status=200
    ${tag_id}    Set Variable    ${tag_response.json()}[data][id]
    Session Storage Set Item    page_ID    ${page_id}
    Session Storage Set Item    tag_ID    ${tag_id}
    Session Storage Set Item    tag_oid    page99
    #Session Storage Set Item    widget_status    edit
    Reload
    Wait For Elements State    .wrapper    visible
    Wait For Element And Click It    id=next_page_url >>> id=goEditWidgetBtn
    Wait For Element And Click It    id=next_page_url >>> id=addWidgetBtn
    Wait For Elements State    .widget-select-body    visible
    Wait For Element And Click It    id=冷氣_btn
    Click With Options    id=airConditioner_div    force=True    delay=100ms
    Sleep    1s
    Wait Until Keyword Succeeds    10s    1s    Get Attribute    id=airConditioner_div    class    ==    widget-group widget-selected
    #Get Attribute    id=airConditioner_div    class    widget-group.widget-selected
    Click With Options    id=set_btn    delay=100ms
    Fill Text    id=title    大冷氣
    Fill Text    id=s_title    小冷氣
    Select Options By    id=data_node_dev    value   13F-VRF-AC-B5-35-F
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    1s
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Get Text    id=next_page_url >>> .sub-title    ==    小冷氣
    Get Text    id=next_page_url >>> .main-title.zh-TW    ==    大冷氣
    ${value}    Get Text    id=next_page_url >>> .chart-value
    Should Not Contain    ${value}    Na
    GET    http://192.168.11.26/setValue?token=0e75c3da607204bf7a4f8ad3a88d93d2c&devid=13F-VRF-AC-B5-35-F&node=TempSet&val=20    headers=&{header}    expected_status=200
    Wait Until Keyword Succeeds    15s    1s    Get Text    databind=13F-VRF-AC-B5-35-FNODETempSet_airConditioner    text    ==    20
    Click With Options    id=next_page_url >>> onclick=widgetEdit(event)    force=True    delay=100ms
    Wait For Element And Click It    id=next_page_url >>> id=delete_submit
    Wait For Elements State    .wrapper    visible
    
