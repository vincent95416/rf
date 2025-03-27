*** Settings ***
Resource    ./task.robot
Suite Setup    Edit Url

*** Test Cases ***
新增widget
    [Tags]    widget
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Elements State    id=btn_area    visible    15s
    Wait For Element And Click It    id=儀表板_btn
    Click With Options    id=dashboard_battery_div    force=True
    #Get Attribute    id=dashboard_battery_div    class    widget-group setting widget-selected
    Sleep    1s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大電池
    Fill Text    id=s_title    小電池
    Fill Text    id=note_info    電池
    Select Options By    id=data_node_dev    value   ${device1}
    Sleep    1s
    Click With Options    id=old_save_Btn    delay=100ms
    Sleep    1s
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Get Text    id=next_page_url >>> .chart-name    ==    電池
    Get Text    id=next_page_url >>> .sub-title    ==    小電池
    Get Text    id=next_page_url >>> .main-title.en    ==    大電池
    ${value}    Get Text    id=next_page_url >>> .chart-value
    Should Not Contain    ${value}    Na

搬移widget
    [Tags]    widget
    Click With Options    id=next_page_url >>> css=button.icon.icon-three-dots.icon-40[onclick='widgetEdit(event)']    delay=200ms
    Click With Options    id=next_page_url >>> //span[@data-i18n='widget.edit.move' and text()='Move Widget']    delay=200ms
    Wait For Elements State    id=next_page_url >>> .modal-content    visible
    Select Options By    id=next_page_url >>> id=widget_page_tag    label    robot2
    Click With Options    id=next_page_url >>> id=widget_edit_submit    delay=200ms
    Click With Options    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot2']    clickCount=2
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Get Text    id=next_page_url >>> .chart-name    ==    電池
    Get Text    id=next_page_url >>> .sub-title    ==    小電池
    Get Text    id=next_page_url >>> .main-title.en    ==    大電池

複製、刪除widget
    [Tags]    widget
    Click With Options    id=next_page_url >>> css=button.icon.icon-three-dots.icon-40[onclick='widgetEdit(event)']    delay=200ms
    Click With Options    id=next_page_url >>> //span[@data-i18n='widget.edit.copy' and text()='Copy Widget']    delay=200ms
    Wait For Elements State    id=next_page_url >>> .modal-content    visible
    Select Options By    id=next_page_url >>> id=widget_page_tag    label    robot1
    Click With Options    id=next_page_url >>> id=widget_edit_submit    delay=200ms
    Sleep    3s
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    #刪除
    Click With Options    id=next_page_url >>> css=button.icon.icon-three-dots.icon-40[onclick='widgetEdit(event)']    delay=200ms
    Click With Options    id=next_page_url >>> .delete    delay=200ms
    Wait For Elements State    id=next_page_url >>> .modal-content    visible
    Wait For Elements State    id=next_page_url >>> id=delete_submit    stable
    Click With Options    id=next_page_url >>> id=delete_submit    delay=500ms
    Sleep    3s
    Wait For Elements State    id=next_page_url >>> .widget-group.widget-s.widget-edit.ui-sortable-handle    detached
    #檢查複製結果
    Click With Options    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='robot1']    clickCount=2
    Wait For Elements State    id=next_page_url >>> .chart-value    visible
    Get Text    id=next_page_url >>> .chart-name    ==    電池
    Get Text    id=next_page_url >>> .sub-title    ==    小電池
    Get Text    id=next_page_url >>> .main-title.en    ==    大電池

編輯widget,告警觸發
    [Tags]    widget
    [Documentation]    修改widget致告警事件觸發
    Click With Options    id=next_page_url >>> .chart-value    clickCount=2    delay=100ms    force=True
    Sleep    1s
    Wait For Elements State    id=dashboard_battery_div    visible
    #Get Attribute    id=dashboard_battery_div    class    widget-group setting widget-selected
    Click With Options    id=set_btn    delay=500ms
    Clear And Input Text    id=baseline_val    1
    Click    id=trigger-1
    Fill Text    id=alert_note    無保請回
    Click With Options    id=old_save_Btn    delay=500ms
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Wait For Elements State    id=next_page_url >>> css=[onclick="switch_triggerMenu(event)"]    visible

事件管理
    Wait For Elements State    id=eventPop_iframe    visible    60s
    Wait For Elements State    id=eventPop_iframe >>> id=all_info_count    stable
    ${text}    Get Text    id=eventPop_iframe >>> id=event_alarm_msg
    Sleep    3s
    Should Contain    ${text}    無保請回
    #檢查告警內容是否包含預期文字,否則點下一頁找尋,最多五次
#    ${page}    Set Variable    0
#    FOR    ${index}    IN RANGE    6
#        ${text}    Get Text    id=eventPop_iframe >>> id=event_alarm_msg
#        ${result}    Run Keyword And Ignore Error    Should Contain    ${text}    無保請回
#        Run Keyword If    '${result[0]}' == 'PASS'    Exit For Loop
#        Run Keyword If    '${result[0]}' == 'FAIL'    Click    id=eventPop_iframe >>> .icon.icon-event-pop-after.icon-28
#        Run Keyword If    '${result[0]}' == 'FAIL'    Sleep    1s
#        Run Keyword If    '${result[0]}' == 'FAIL'    Set Variable    ${page}    ${page} + 1
#    END
#    Sleep    1s
    Go To    ${url}/event/eventList.html?token=${token}&language=en
    Wait For Elements State    id=next_page_url >>> css=body    visible
    Get Text    id=next_page_url >>> xpath=/html/body/main/div[2]/ul/li[1]/div[1]/div[2]/div[1]/div[2]/span[2]    ==    未處理
    Get Text    id=next_page_url >>> xpath=/html/body/main/div[2]/ul/li[1]/div[1]/div[2]/div[2]/span[4]    ==    ${text}
    Click With Options    id=next_page_url >>> .ev-link    delay=100ms
    Wait For Elements State    id=next_page_url    visible
    Get Attribute    id=next_page_url >>> xpath=/html/body/div[1]/div/div/div[2]/div    class    ==    widget-group widget-s widget-view event-widget
    Click    id=next_page_url >>> .more-btn more-alarm-close
    Wait For Elements State    id=next_page_url >>> .trigger-menu list-group d-block    visible
    Click With Options    id=next_page_url >>> //span[@data-i18n='widget.edit.trigger_close' and text()='關閉告警']

刪除widget
    [Tags]    widget
    Go To    ${main_url}&uid=${uid}&title=robot_page&em=Edit
    Click With Options    id=next_page_url >>> css=button.icon.icon-three-dots.icon-40[onclick='widgetEdit(event)']    delay=200ms
    Click With Options    id=next_page_url >>> .delete    delay=200ms
    Wait For Elements State    id=next_page_url >>> .modal-content    visible
    Wait For Elements State    id=next_page_url >>> id=delete_submit    stable
    Click With Options    id=next_page_url >>> id=delete_submit    delay=500ms
    Sleep    3s
    Wait For Elements State    id=next_page_url >>> .widget-group.widget-s.widget-edit.ui-sortable-handle    detached