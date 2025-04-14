*** Settings ***
Resource    ./task.robot
Suite Setup    Continues_page

*** Variables ***
&{header}    Content-Type=application/json
&{newuser_payload}    groupId=00000000-0000-0000-0000-000000000000    acc=0000    pwd=0000    name=robot_admin
&{newpage_payload}    parent=00000000-0000-0000-0000-000000000000    oid1=menu99    oid2=robot_page    oid3=nav_ic_bulletin    oi4=[]    oid5=00000000-0000-0000-0000-000000000000    groudid=00000000-0000-0000-0000-000000000000

*** Test Cases ***
頁面標籤、widget新增
    [Documentation]    送出page和tag的req並且利用session存取頁面
    ${page_response}    POST    url=http://192.168.11.26/TreeData/treedata/?token=${token}    headers=&{header}    json=&{newpage_payload}    expected_status=200
    ${page_data}    Set Variable    ${page_response.json()}[data]
    Log    ${page_data}
    ${page_id}    Set Variable    ${page_data}[id]
    &{newtag_payload}    Create Dictionary    parent=${page_id}    oid1=page99    oid2=robot_tag    oid4=00000000-0000-0000-0000-000000000000    oid5=100    groudid=00000000-0000-0000-0000-000000000000
    ${tag_response}    POST    url=http://192.168.11.26/TreeData/treedata/?token=${token}    headers=&{header}    json=&{newtag_payload}    expected_status=200
    ${tag_id}    Set Variable    ${tag_response.json()}[data][id]

    &{secondtag_payload}    Create Dictionary    parent=${page_id}    oid1=page98    oid2=robot_tag2    oid4=00000000-0000-0000-0000-000000000000    oid5=100    groudid=00000000-0000-0000-0000-000000000000
    POST    url=http://192.168.11.26/TreeData/treedata/?token=${token}    headers=&{header}    json=&{secondtag_payload}    expected_status=200

    Session Storage Set Item    page_ID    ${page_id}
    Session Storage Set Item    tag_ID    ${tag_id}
    Session Storage Set Item    tag_oid    page99
    Session Storage Set Item    widget_status    edit
    Reload
    Sleep    3s
    Wait For Elements State    .wrapper    visible
    Wait For Element And Click It    id=next_page_url >>> id=goEditWidgetBtn
    Wait For Element And Click It    id=next_page_url >>> id=addWidgetBtn
    Wait For Elements State    .widget-select-body    visible
    Wait For Element And Click It    id=冷氣_btn
    Click With Options    id=airConditioner_div    force=True    delay=100ms
    Sleep    1s
    Wait Until Keyword Succeeds    10s    1s    Get Attribute    id=airConditioner_div    class    ==    widget-group widget-selected
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
    Wait For Elements State    id=next_page_url >>> p[databind="13F-VRF-AC-B5-35-FNODETempSet_airConditioner"]    visible
    ${now_temp}    Get Text    id=next_page_url >>> p[databind="13F-VRF-AC-B5-35-FNODETempSet_airConditioner"]
    ${set_temp}    Evaluate    int(${now_temp}) + 1
    ${set_temp}    Set Global Variable    ${set_temp}

widget告警trigger、setvalue
    [Documentation]    延續冷氣widget，做setvalue。接著改為儀表板驗證trigger
    Wait For Elements State    id=next_page_url >>> .widget-body    visible
    Click With Options    id=next_page_url >>> .main-title.zh-TW    clickCount=2    delay=100ms    force=True
    Wait For Element And Click It    id=儀表板_btn
    Click With Options    id=dashboard_battery_div    force=True    delay=100ms
    Sleep    1s
    Wait Until Keyword Succeeds    10s    1s    Get Attribute    id=dashboard_battery_div    class    ==    widget-group widget-selected
    Click With Options    id=set_btn    delay=100ms
    Select Options By    id=data_node_nodes    value    VTP-0001
    Fill Text    id=baseline_val    1
    Click With Options    id=trigger-1    delay=100ms
    Fill Text    id=alert_note    惡性罷免
    Click With Options    id=old_save_Btn
#    ${onclick_value}    Get Attribute    id=next_page_url >>> xpath=//a[@class='btn']/span[@data-i18n='widget.edit.trigger_close']/parent::a    onclick
#    ${trigger_id}    Evaluate    "${onclick_value}".split("'")[1]
#    Log    ${trigger_id}
    &{headers}    Create Dictionary    Content-Type=application/json    Authorization=${token}
    Sleep    5s
    GET    url=http://192.168.11.26/setValue?token=${token}&devid=13F-VRF-AC-B5-35-F&node=TempSet&val=${set_temp}    headers=&{headers}    expected_status=200
    Wait For Elements State    id=event_block    visible    60s
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
    Click With Options    id=next_page_url >>> id=delete_submit    delay=100ms
    Wait For Elements State    id=next_page_url >>> .widget-title    hidden
    #DELETE    url=http://192.168.11.26/api/Trigger/del?triggerid=${trigger_id}    headers=&{headers}    expected_status=200
    DELETE    url=http://192.168.11.26/TreeData/treedata/${page_id}    headers=&{headers}