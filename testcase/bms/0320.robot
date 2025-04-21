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
    New Page    http://192.168.11.26    load
    #Log    Testing version ${VERSION} in ${environment} environment

Continuous page
    New Browser    chromium    headless=True    slowMo=1
    New Page    ${main_url}

*** Variables ***
&{header}    Content-Type=application/json

&{payload}    acc=admin    pwd=P@ssw0rd
&{newpage_payload}    parent=00000000-0000-0000-0000-000000000000    oid1=menu99    oid2=robot_page    oid3=nav_ic_bulletin    oi4=[]    oid5=00000000-0000-0000-0000-000000000000    groudid=00000000-0000-0000-0000-000000000000
#&{newtag_body}    parent=${page_id}    oid1=menu99999999    oid2=robot_tag    oid5=00000000-0000-0000-0000-000000000000    groudid=00000000-0000-0000-0000-000000000000

*** Test Cases ***
登入
#    #New Page    http://192.168.11.22    load
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

    Wait For Elements State    id=next_page_url >>> p[databind="13F-VRF-AC-B5-35-FNODETempSet_airConditioner"]    visible
    ${now_temp}    Get Text    id=next_page_url >>> p[databind="13F-VRF-AC-B5-35-FNODETempSet_airConditioner"]
    ${set_temp}    Evaluate    int(${now_temp}) + 1
    &{headers}    Create Dictionary    Content-Type=application/json    Authorization=${token}
    Sleep    5s
    GET    url=http://192.168.11.26/setValue?token=${token}&devid=13F-VRF-AC-B5-35-F&node=TempSet&val=${set_temp}    headers=&{headers}    expected_status=200
    Wait For Elements State    id=event_block    visible    15s
    Wait For Elements State    id=eventPop_iframe >>> id=all_info_count    stable
    Sleep    3s
    #檢查告警內容是否包含預期文字,否則點下一頁找尋,最多十次
    ${alarm_page}    Set Variable    0
    FOR    ${index}    IN RANGE    10
        ${alarm_msg}    Get Text    id=eventPop_iframe >>> id=event_alarm_msg
        ${result}    Run Keyword And Ignore Error    Should Contain    ${alarm_msg}    惡性罷免
        Run Keyword If    '${result[0]}' == 'PASS'    Exit For Loop
        Run Keyword If    '${result[0]}' == 'FAIL'    Click    id=eventPop_iframe >>> .icon.icon-event-pop-after.icon-28
        Run Keyword If    '${result[0]}' == 'FAIL'    Sleep    1s
        Run Keyword If    '${result[0]}' == 'FAIL'    Set Variable    ${alarm_page}    ${alarm_page} + 1
    END
    Click With Options    id=eventPop_iframe >>> .icon.icon-minus-fill-gray.icon-40    delay=200ms
    Wait For Elements State    id=eventPop_iframe >>> id=event-pop-body    hidden
    Click With Options    id=next_page_url >>> button[onclick="widgetEdit(event)"]    delay=200ms
    Wait For Elements State    id=next_page_url >>> .widget-menu.list-group.d-block    visible
    Click With Options    id=next_page_url >>> span[data-i18n="widget.edit.delete"]    delay=200ms    force=True
    Click With Options    id=next_page_url >>> id="delete_submit"    delay=100ms
    Wait For Elements State    id=next_page_url    hidden