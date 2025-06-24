*** Settings ***
Resource    ./task.robot
Suite Setup    Continues Page

*** Variables ***
&{headers}    Content-Type=application/json    Authorization=${token}    Accept=application/json    User-Agent=RobotFramework    Connection=keep-alive

*** Test Cases ***
設備管理
    [Documentation]    建立新的虛擬設備並建立虛擬點位(送api)後，刪除整個設備(會連帶觸發刪除點位api)
    Reload
    Wait For Element And Click It    id=device_management
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> p[data-i18n='system.tag.device']    delay=100ms
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    ${device_id_virtual}    Get Attribute    id=devid    value
    Fill Text    id=name    robotvdev
    Click With Options    id=organize    delay=200ms
    Wait For Elements State     .dropdown-menu.show    visible
    Click With Options    button[onclick="setDropdownItem(event, 'departments_list', 'A組織')"]    delay=300ms
    Get Text    id=organize    ==    A組織
    Click With Options    button[onclick="showDeviceListModal('binding')"]    delay=200ms
    Sleep    1s
    # 被::before擋住，只能用下下策的js語法來操作checkbox
    Evaluate JavaScript    ${None}    document.querySelector("[value='dv_002']").checked = true
    Evaluate JavaScript    ${None}    document.querySelector("[value='dv_003']").checked = true
    ...    verifyDeviceListModalSubmit()
    Click With Options    id=deviceList_submit    delay=100ms
    Wait For Elements State    id=basicOffcanvas_submit    enabled
    Click With Options    id=basicOffcanvas_submit    delay=200ms
    Sleep    1s
    ${device_response}    GET    url=${url}api/Device/list    headers=&{headers}    expected_status=200
    Assert Result 0    ${device_response}
    ${device_list}    Set Variable    ${device_response.json()}[data]
    ${device_id}    Set Variable    ${None}
    FOR    ${device}    IN    @{device_list}
        ${current_name}    Set Variable    ${device}[name]
        ${current_id}    Set Variable    ${device}[id]
        # 檢查name
        IF    '${current_name}' == 'robotvdev'
            ${device_id}    Set Variable    ${current_id}
            Exit For Loop
        END
    END
    &{node_data}    Create Dictionary    id=VTP-9999    name=robot_vtnode
    @{nodes_list}    Create List    ${node_data}
    ${post_payload}    Create Dictionary    devid=${device_id}    nodes=@{nodes_list}
    ${post_response}    POST    url=${url}api/Device/addDevNode    headers=&{headers}    json=${post_payload}    expected_status=200
    Assert Result 0    ${post_response}
    ${del_payload}    Create Dictionary    devid=${device_id}    id=VTP-9999
#    ${del_response}    DELETE    url=http://192.168.11.26/api/Device/delDevNode    headers=&{headers}    json=${del_payload}
#    Assert Result 0    ${del_response}
    # 編輯、刪除表單第一項
    Get Attribute    id=next_page_url >>> xpath=/html/body/main/div[2]/div[2]/div/div[2]/div[1]/div[4]    title    ==    robotvdev
    Click With Options    id=next_page_url >>> xpath=/html/body/main/div[2]/div[2]/div/div[2]/div[1]/div[9]/button[2]    delay=100ms
    Sleep    1s
    Get Text    id=deleteConfirmModal_item    ==    robotvdev
    Click With Options    id=deleteConfirmModal_submit    delay=300ms

情境管理
    [Documentation]    建立一筆新情境用送api刪除(因頁面列表無法準確指向，故只能打api)
    Reload
    Wait For Element And Click It    id=device_management
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> p[data-i18n='system.tag.script']    delay=100ms
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Select Options By    id=script_script_type_script_type    value    1
    Wait For Elements State    .ui-sortable    visible
    Fill Text    id=script_name_name    robot_scenario
    Select Options By    id=script_script_action_device_1    value    Do_123
    Select Options By    id=script_script_action_node_1    value    Do_04
    Select Options By    id=script_script_action_di_node_value_1    value    0
    Wait For Elements State    id=basicOffcanvas_submit    enabled
    Click With Options    id=basicOffcanvas_submit    delay=200ms
    Sleep    1s
    ${scenario_response}    GET    url=${url}SerialScript?token=${token}    headers=&{headers}    expected_status=200
    Assert Result 0    ${scenario_response}
    ${scripts_list}    Set Variable    ${scenario_response.json()}[scripts]
    ${script_id}    Set Variable    ${None}
    FOR    ${script}    IN    @{scripts_list}
        ${current_name}    Set Variable    ${script}[name]
        ${current_id}    Set Variable    ${script}[scriptid]
        # 檢查name
        IF    '${current_name}' == 'robot_scenario'
            ${script_id}    Set Variable    ${current_id}
            Exit For Loop
        END
    END
    # 印出id到log
    Run Keyword If    '${script_id}' != '${None}'
    ...    Log    已找到新建立的情境ID : ${script_id}
#    Click With Options    id=next_page_url >>> button[@onclick='editItem('script', '${script_id}', 'edit')']    delay=200ms
#    Fill Text    id=script_name_name    0robot_scenario
#    Wait For Elements State    id=basicOffcanvas_submit    enable
#    Click With Options    id=basicOffcanvas_submit    delay=200ms
#    Sleep    1s
#    Click With Options    id=next_page_url >>> button[@onclick='deleteItem('script', '${script_id}')']    delay=200ms
#    Wait For Elements State    div[@class='modal fade show' and @id=deleteConfirmModal]    visible
#    Get Text    id=deleteConfirmModal_item    ==    0robot_scenario
#    Click With Options    id=deleteConfirmModal_submit    delay=200ms
    ${put_response}    PUT    url=${url}SerialScript/${script_id}    headers=${headers}    expected_status=200
    Assert Result 0    ${put_response}
    ${del_response}    DELETE    url=${url}SerialScript/${script_id}    headers=${headers}    expected_status=200
    Assert Result 0    ${del_response}

自動化管理
    [Documentation]    建立一筆新自動化trigger後用送api刪除(因頁面列表無法準確指向，故只能打api)
    Reload
    Wait For Element And Click It    id=device_management
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> p[data-i18n='system.tag.auto']    delay=100ms
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Fill Text    id=automated_name_name    robot_automation
    Select Options By    id=automated_trigger_condition_condition_type    value    2
    Click With Options    id=automated_trigger_condition_timing_0    delay=100ms
    Select Options By    id=automated_trigger_condition_schedule_timing_0    value    00:00
    Select Options By    id=automated_automated_control_device    value    Do_123
    Select Options By    id=automated_automated_control_node    value    Do_04
    Select Options By    id=automated_automated_control_di_node_value    value    0
    Wait For Elements State    id=basicOffcanvas_submit    enabled
    Click With Options    id=basicOffcanvas_submit    delay=200ms
    Sleep    1s
    ${trigger_response}    GET    url=${url}api/Trigger/list?groupId=00000000-0000-0000-0000-000000000000&status=-1    headers=&{headers}    expected_status=200
    Assert Result 0    ${trigger_response}
    ${trigger_list}    Set Variable    ${trigger_response.json()}[data]
    ${trigger_id}    Set Variable    ${None}
    FOR    ${trigger}    IN    @{trigger_list}
        ${current_name}    Set Variable    ${trigger}[name]
        ${current_id}    Set Variable    ${trigger}[triggerid]
        # 檢查name
        IF    '${current_name}' == 'robot_automation'
            ${trigger_id}    Set Variable    ${current_id}
            Exit For Loop
        END
    END
    # 印出id到log
    Run Keyword If    '${trigger_id}' != '${None}'
    ...    Log    已找到新建立的自動化id : ${trigger_id}
    # 開關觸發、刪除
    ${set_response}    POST    url=${url}api/Trigger/setEnable?triggerid=${trigger_id}&enable=0    headers=&{headers}    expected_status=200
    Assert Result 0    ${set_response}
    ${del_response}    DELETE    url=${url}api/Trigger/del?triggerid=${trigger_id}    headers=&{headers}    expected_status=200
    Assert Result 0    ${del_response}

多條件告警
    [Documentation]    建立一筆新多條件trigger後用送api刪除(因頁面列表無法準確指向，故只能打api)
    Reload
    Wait For Element And Click It    id=device_management
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> p[data-i18n='system.tag.trigger']    delay=100ms
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Fill Text    input[placeholder='請輸入名稱']    robot_multi-trigger
    Select Options By    xpath=/html/body/div[14]/div/div[2]/div[3]/div/select    value    0
    Select Options By    .form-control.border-radius-top    value    Do_123
    Select Options By    .form-control.border-radius-bottom    value    Do_04
    Select Options By    xpath=/html/body/div[14]/div/div[2]/div[3]/div[2]/div/div[4]/select    value    0
    Fill Text    xpath=/html/body/div[14]/div/div[2]/div[5]/div[2]/textarea    robot_textarea
    Wait For Elements State    xpath=/html/body/div[14]/div/div[3]/button[2]    enabled
    Click With Options    xpath=/html/body/div[14]/div/div[3]/button[2]    delay=200ms
    Sleep    1s
    ${trigger_response}    GET    url=${url}api/Trigger/list?groupId=00000000-0000-0000-0000-000000000000&status=-1    headers=&{headers}    expected_status=200
    Assert Result 0    ${trigger_response}
    ${trigger_list}    Set Variable    ${trigger_response.json()}[data]
    ${trigger_id}    Set Variable    ${None}
    FOR    ${trigger}    IN    @{trigger_list}
        ${current_name}    Set Variable    ${trigger}[name]
        ${current_id}    Set Variable    ${trigger}[triggerid]
        # 檢查name
        IF    '${current_name}' == 'robot_multi-trigger'
            ${trigger_id}    Set Variable    ${current_id}
            Exit For Loop
        END
    END
    # 印出id到log
    Run Keyword If    '${trigger_id}' != '${None}'
    ...    Log    已找到新建立的多條件id : ${trigger_id}
    # 開關觸發、刪除
    ${set_response}    POST    url=${url}api/Trigger/setEnable?triggerid=${trigger_id}&enable=0    headers=&{headers}    expected_status=200
    Assert Result 0    ${set_response}
    ${del_response}    DELETE    url=${url}api/Trigger/del?triggerid=${trigger_id}    headers=&{headers}    expected_status=200
    Assert Result 0    ${del_response}

需量管理
    [Documentation]    建立一筆需量後用送api刪除(因頁面列表無法準確指向，故只能打api)
    Reload
    Wait For Element And Click It    id=device_management
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Click With Options    id=next_page_url >>> p[data-i18n='system.tag.demand']    delay=100ms
    Click With Options    id=next_page_url >>> id=add-item-btn    delay=100ms
    Wait For Elements State    .offcanvas.offcanvas-s.show    visible
    Fill Text    id=demand_name_name    robot_demand
    Select Options By    id=demand_demand_target_device    value    ${device_id}
    Select Options By    id=demand_demand_target_node    value    FanSpeed
    Fill Text    id=demand_demand_target_value    1
    Fill Text    id=demand_execute_action_target_val_1    1
    Select Options By    id=demand_execute_action_execute_type_1    value    1
    Select Options By    id=demand_execute_action_device_1    value    Do_123
    Select Options By    id=demand_execute_action_node_1    value    Do_04
    Select Options By    id=demand_execute_action_di_node_value_1    value    0
    Wait For Elements State    id=basicOffcanvas_submit    enabled
    Click With Options    id=basicOffcanvas_submit    delay=200ms
    Sleep    1s
    ${demand_response}    GET    url=${url}demandControl/config/?token=${token}    headers=&{headers}    expected_status=200
    Assert Result 0    ${demand_response}
    ${demand_list}    Set Variable    ${demand_response.json()}[cfgs]
    ${demand_id}    Set Variable    ${None}
    FOR    ${demand}    IN    @{demand_list}
        ${current_name}    Set Variable    ${demand}[name]
        ${current_id}    Set Variable    ${demand}[id]
        # 檢查name
        IF    '${current_name}' == 'robot_demand'
            ${demand_id}    Set Variable    ${current_id}
            Exit For Loop
        END
    END
    Run Keyword If    '${demand_id}' != '${None}'
    ...    Log    已找到需量id : ${demand_id}
    # 開關觸發、刪除
    ${set_response}    POST    url=${url}api/Trigger/setEnable?triggerid=${demand_id}&enable=0    headers=&{headers}    expected_status=200
    Assert Result 0    ${set_response}
    ${del_response}    DELETE    url=${url}demandControl/config/${demand_id}    headers=&{headers}    expected_status=200
    Assert Result 0    ${del_response}