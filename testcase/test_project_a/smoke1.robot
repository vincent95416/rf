*** Settings ***
Resource    ./task.robot
Suite Setup    Continues_page

*** Variables ***
&{headers}    Content-Type=application/json    Authorization=${token}

*** Test Cases ***
module1
    [Documentation]    送出page和tag的api並且利用session直接存取頁面；在新頁面/標籤，建立widget
    &{newpage_payload}    Create Dictionary    parent=00000000-0000-0000-0000-000000000000    oid1=menu99    oid2=robot_page    oid3=nav_ic_bulletin    oi4=[]    oid5=00000000-0000-0000-0000-000000000000    groudid=00000000-0000-0000-0000-000000000000
    ${page_response}    POST    url=${url}TreeData/treedata/?token=${token}    headers=&{headers}    json=&{newpage_payload}    expected_status=200
    Assert Result 0    ${page_response}
    ${page_data}    Set Variable    ${page_response.json()}[data]
    Log    ${page_data}
    ${page_id}    Set Variable    ${page_data}[id]
    Set Global Variable    ${menu_id}    ${page_id}
    &{newtag_payload}    Create Dictionary    parent=${page_id}    oid1=page99    oid2=robot_tag    oid4=00000000-0000-0000-0000-000000000000    oid5=100    groudid=00000000-0000-0000-0000-000000000000
    ${tag_response}    POST    url=${url}TreeData/treedata/?token=${token}    headers=&{headers}    json=&{newtag_payload}    expected_status=200
    Assert Result 0    ${tag_response}
    ${tag_id}    Set Variable    ${tag_response.json()}[data][id]

    &{secondtag_payload}    Create Dictionary    parent=${page_id}    oid1=page98    oid2=robot_tag2    oid4=00000000-0000-0000-0000-000000000000    oid5=100    groudid=00000000-0000-0000-0000-000000000000
    ${secondtag_response}    POST    url=${url}TreeData/treedata/?token=${token}    headers=&{headers}    json=&{secondtag_payload}    expected_status=200
    Assert Result 0    ${secondtag_response}

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
    Select Options By    id=data_node_dev    value   ${deviceID}
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    1s
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Get Text    id=next_page_url >>> .sub-title    ==    小冷氣
    Get Text    id=next_page_url >>> .main-title.zh-TW    ==    大冷氣
    Wait For Elements State    id=next_page_url >>> p[databind="${deviceID}NODETempSet_airConditioner"]    visible
    ${now_temp}    Get Text    id=next_page_url >>> p[databind="${deviceID}NODETempSet_airConditioner"]
    ${expected_temp}    Evaluate    int(${now_temp}) + 1
    Set Global Variable    ${set_temp}    ${expected_temp}

module2
    [Documentation]    延續冷氣widget，編輯為儀表板驗證setValue後的event-pop trigger
    Wait For Elements State    id=next_page_url >>> .widget-body    visible
    Click With Options    id=next_page_url >>> .main-title.zh-TW    clickCount=2    delay=100ms    force=True
    Wait For Element And Click It    id=儀表板_btn
    Click With Options    id=dashboard_battery_div    force=True    delay=100ms
    Sleep    1s
    Wait Until Keyword Succeeds    10s    1s    Get Attribute    id=dashboard_battery_div    class    ==    widget-group widget-selected
    Click With Options    id=set_btn    delay=100ms
    Select Options By    id=data_node_nodes    value    VTP-0001
    Click With Options    id=trigger_switch    delay=200ms
    Sleep    1s
    Get Attribute    id=trigger_switch    class    ==    mr-12 icon-switch-on
    Click With Options    xpath=/html/body/div[4]/div/div[2]/div[4]/div/div[4]/div[2]    delay=300ms    force=True
    Select Options By    id=widget_trigger_compare    value    2
    Fill Text    id=widget_trigger_compare_val    1
    #Click With Options    id=widget_trigger_frequency_1    delay=100ms
    Fill Text    id=widget_trigger_content    惡性罷免
    Click With Options    id=old_save_Btn
#    ${onclick_value}    Get Attribute    id=next_page_url >>> xpath=//a[@class='btn']/span[@data-i18n='widget.edit.trigger_close']/parent::a    onclick
#    ${trigger_id}    Evaluate    "${onclick_value}".split("'")[1]
#    Log    ${trigger_id}
    #&{headers}    Create Dictionary    Content-Type=application/json    Authorization=${token}
    Sleep    5s
    ${setvalue_response}    GET    url=${url}setValue?token=${token}&devid=${deviceID}&node=TempSet&val=${set_temp}    headers=&{headers}    expected_status=200
    Assert Result 0    ${setvalue_response}
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
    ${delpage_response}    DELETE    url=${url}TreeData/treedata/${menu_id}    headers=&{headers}    expected_status=200
    Assert Result 0    ${delpage_response}