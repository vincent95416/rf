*** Settings ***
Resource    ./task.robot
Suite Setup    Continuous page

*** Test Cases ***
widget編輯模式
    Wait For Load State    load    30
    Wait For Elements State    css=body    visible
    Wait For Element And Click It    id=next_page_url >>> id=btn_show_widget
    Wait For Elements State    id=next_page_url >>> css=body    visible

新增平面圖
    [Tags]    map
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Hover    id=menu_aside
    Wait For Element And Click It    //p[contains(text(), '測試')]
    Click With Options    id=next_page_url >>> //p[@class='mb-0 d-inline-block text-truncate' and text()='${init_label}']    clickCount=2
    Wait For Element And Click It    id=next_page_url >>> id=btn_add_widget
    Wait For Element And Click It    id=平面圖_btn
    #Click With Options    id=XL_cardType_widgets    force=True
    #現在onclick事件有bug,無法選中XL的平面圖widget,因此改執行下兩行程式碼
    Click With Options    xpath=/html/body/div[3]/div[2]/div[1]/div/div/div[1]/p[2]    delay=200ms
    Get Attribute    id=Map_L_div    class    ==    widget-group widget-donut widget-selected
    Sleep    2s
    Click With Options    id=set_btn    delay=300ms
    Fill Text    id=title    大平面圖
    Fill Text    id=s_title    小平面圖
    Click With Options    .btn-clear.d-flex.flex-row.align-items-center.f-16-600.c-blue.mt-2.mb-3    delay=200ms
    Wait For Elements State    id=iframe_map >>> css=body    visible    15s
    Upload File By Selector    id=iframe_map >>> input#file2    53W8K9.jpg
    Click With Options    id=iframe_map >>> id=upload_submit    delay=200ms
    Get Text    id=status_msg_content    ==    已上傳
    Get Attribute    id=iframe_map >>> id=nomap_icon    class    ==    icon icon-100 icon-nomap d-none
    Get Text    id=iframe_map >>> id=map_name_show    ==    53W8K9.jpg
    #icon新增
    Wait For Element And Click It    id=iframe_map >>> id=add_widget_btn
    Wait For Elements State    id=iframe_map >>> id=iframe_map_widget >>> css=body    visible    15s
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=device_model_select    value    6
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=next_widget_btn    delay=300ms
    Get Attribute    id=iframe_map >>> id=iframe_map_widget >>> id=step2_title    class    ==    path active
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=data_node_dev    value    ${device1}
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=add_btn    delay=200ms
    Sleep    1s
    ${icon1}    Get Element    id=iframe_map >>> css=span[databind='${device1}NODEco']
    Hover    ${icon1}
    Wait For Elements State    id=iframe_map >>> .map_widget_hover    visible
    ${nowrap1}    Get text    id=iframe_map >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div[2]/div[2]
    Should Contain    ${nowrap1}    室內空氣品質：
    Sleep    1s
    Click With Options    id=iframe_map >>> id=Save_Btn    delay=200ms
    Click With Options    id=old_save_Btn    delay=200ms
    Sleep    3s

編輯平面圖
    [Tags]    map
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Click With Options    id=next_page_url >>> css=button.icon.icon-three-dots.icon-40[onclick='widgetEdit(event)']    delay=200ms
    Click    id=next_page_url >>> css=span[data-i18n='widget.edit.map']
    Wait For Elements State    id=iframe_map >>> css=body    visible    15s
    Upload File By Selector    id=iframe_map >>> input#file2    90909.jpg
    Sleep    1s
    Click With Options    id=iframe_map >>> id=upload_submit    delay=200ms
    Sleep    1s
    Wait For Elements State    id=iframe_map >>> id=map_name_show    stable
    Get Text    id=iframe_map >>> id=map_name_show    ==    90909.jpg
    #icon處理,刪除、編輯等動作
    Click With Options    id=iframe_map >>> .widget-box    delay=500ms    button=right
    Wait For Elements State    id=iframe_map >>> id=menu    visible
    Click With Options    id=iframe_map >>> id=Edit_btn    delay=200ms
    Wait For Elements State    id=iframe_map >>> id=iframe_map_widget >>> id=widget_demo_view_area    visible
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=next_widget_btn    delay=300ms
    Fill Text    id=iframe_map >>> id=iframe_map_widget >>> id=unit    Q
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=add_btn    delay=100ms
    Get Text    id=iframe_map >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div/span[2]    ==    Q
    Click With Options    id=iframe_map >>> .widget-box    delay=500ms    button=right
    Wait For Elements State    id=iframe_map >>> id=menu    visible
    Click With Options    id=iframe_map >>> id=Del_btn   delay=200ms
    Wait For Elements State    id=iframe_map >>> .widget-box    detached
    #新增不同種類icon，後續複製
    Wait For Element And Click It    id=iframe_map >>> id=add_widget_btn
    Wait For Elements State    id=iframe_map >>> id=iframe_map_widget >>> css=body    visible    15s
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=device_model_select    value    3
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=widget_icon_select    label    Ao
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=next_widget_btn    delay=300ms
    Get Attribute    id=iframe_map >>> id=iframe_map_widget >>> id=step2_title    class    ==    path active
    Select Options By    id=iframe_map >>> id=iframe_map_widget >>> id=data_node_dev    value    ${device2}
    Click With Options    id=iframe_map >>> id=iframe_map_widget >>> id=add_btn    delay=200ms
    Sleep    1s
    ${icon2}    Get Element    id=iframe_map >>> css=span[databind='${device2}NODEKWHDay']
    Hover    ${icon2}
    Wait For Elements State    id=iframe_map >>> .map_widget_hover    visible
    ${nowrap3}    Get text    id=iframe_map >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div[2]/div[5]
    Should Contain    ${nowrap3}    風速：
    Sleep    1s
    Click With Options    ${icon2}    delay=500ms    button=right
    Wait For Elements State    id=iframe_map >>> .menu    visible
    Click With Options    id=iframe_map >>> id=Copy_btn
    @{box}    Get Elements    id=iframe_map >>> .widget-box
    Length Should Be    ${box}    2
    Get Widget ID    id=iframe_map    src
    Click With Options    id=iframe_map >>> id=Save_Btn    delay=200ms
    Sleep    1s
    @{map_icon}    Get Elements    id=next_page_url >>> id=${WIDGET_ID}_MAP >>> .dragItem.widget-map.ao.show.offline
    Length Should Be    ${map_icon}    2
    ${outside_nowrap3}    Get Text    id=next_page_url >>> id=${WIDGET_ID}_MAP >>> xpath=/html/body/div[2]/div[2]/div/div[2]/div[2]/div[3]/span[2]
    Should Contain    ${outside_nowrap3}    ${nowrap3}

刪除平面圖
    [Tags]    map
    Click With Options    id=next_page_url >>> css=button.icon.icon-three-dots.icon-40[onclick='widgetEdit(event)']    delay=200ms
    Wait For Elements State    id=next_page_url >>> .widget-menu.list-group.d-block    visible
    Click With Options    id=next_page_url >>> .delete    delay=200ms    force=True
    Wait For Elements State    id=next_page_url >>> .modal.fade.show    visible
    Click With Options    id=next_page_url >>> id=delete_submit    delay=200ms
    Wait For Elements State    id=next_page_url >>> css=body    visible    15s
    Wait For Elements State    id=next_page_url >>> id=${WIDGET_ID}_MAP    detached