*** Settings ***
Resource    ./task.robot
Suite Setup    Continuous Page

*** Test Cases ***
smoke1_頁面標籤新增
    ${page_response}    POST    url=http://192.168.11.22/TreeData/treedata/?token=${token}    headers=&{header}    json=&{newpage_body}    expected_status=200
    ${page_data}    Set Variable    ${page_response.json()}[data]
    Log    ${page_data}
    ${page_id}    Set Variable    ${page_data}[id]
    &{newtag_body}    Create Dictionary    parent=${page_id}    oid1=page99    oid2=robot_tag    oid4=00000000-0000-0000-0000-000000000000    oid5=100    groudid=00000000-0000-0000-0000-000000000000
    ${tag_response}    POST    url=http://192.168.11.22/TreeData/treedata/?token=${token}    headers=&{header}    json=&{newtag_body}    expected_status=200
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
    Click With Options    id=dashboard_battery_div    force=True
    Wait For Element And Click It    id=chartdashboard_battery_mini_widget
    Sleep    1s
    Get Attribute    id=airConditioner_div    class    widget-group.widget-selected
    Click With Options    id=set_btn    delay=100ms
    Fill Text    id=title    大冷氣
    Fill Text    id=s_title    小冷氣
    Select Options By    id=data_node_dev    value   13F-VRF-AC-B5-34-F
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    1s
    Wait For Elements State    id=next_page_url >>> .wrapper    visible
    Get Text    id=next_page_url >>> .sub-title    ==    小冷氣
    Get Text    id=next_page_url >>> .main-title.zh-TW    ==    大冷氣
    ${value}    Get Text    id=next_page_url >>> .chart-value
    Should Not Contain    ${value}    Na
    GET    http://192.168.11.22/setValue?token=0e75c3da607204bf7a4f8ad3a88d93d2c&devid=13F-VRF-AC-B5-34-F&node=TempSet&val=20    headers=&{header}    expected_status=200
    Wait For Element And Click It    onclick=widgetEdit(event)








#    PUT    url=http://192.168.11.22/TreeData/treedata/${page_id}?token=${token}    headers=&{header}    json=&{newpage_body}    expected_status=200
    #DELETE    url=http://192.168.11.22/TreeData/treedata/${page_id}?token=${token}    expected_status=200