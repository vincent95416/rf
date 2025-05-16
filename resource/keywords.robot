*** Settings ***
Library    Browser
Library    DateTime
Library    String
Resource    ../resource/keywords.robot
Variables    ../resource/environment_variables.py
*** Keywords ***
Wait for element and click it
    [Arguments]    ${locator}
    Wait For Elements State    ${locator}    enabled    timeout=10
    Click    ${locator}

Wait for element and input
    [Arguments]    ${locator}    ${value}
    Wait For Elements State    ${locator}    visible    timeout=10
    Fill Text    ${locator}    ${value}

Clear and Input text
    [Arguments]    ${locator}    ${text}
    Wait For Elements State    ${locator}    visible    timeout=10
    Fill Text    ${locator}    ${text}

Get Widget ID
    [Arguments]    ${locator}    ${attr}
    ${src}    Get Attribute    ${locator}    ${attr}
    # 使用String library來解析URL參數
    ${url_parts}=    Split String    ${src}    ?    1
    ${params_string}=    Set Variable    ${url_parts}[1]
    ${params_list}=    Split String    ${params_string}    &
    # 遍歷參數找到widgetID
    FOR    ${param}    IN    @{params_list}
        ${param_parts}=    Split String    ${param}    =
        ${param_name}=    Set Variable    ${param_parts}[0]
        IF    '${param_name}' == 'widgetID'
            ${widget_id}=    Set Variable    ${param_parts}[1]
            Set Global Variable    ${WIDGET_ID}    ${widget_id}    # 設為全域變數
            RETURN    ${widget_id}
        END
    END
    
Check Onclick Hidden
    [Arguments]    ${locator}    ${text}
    ${elements}    Get Elements    ${locator}
    FOR    ${element}    IN    @{elements}
        ${attr}    Get Attribute    ${element}    onclick
        Run Keyword If    "${attr}" == "${text}"    Fail
    END

Extract Token From URL
    [Arguments]    ${url}
    ${parts}=    Split String    ${url}    token=
    ${token_and_rest}=    Split String    ${parts[1]}    &
    ${Token}=    Set Variable    ${token_and_rest[0]}
    Set Global Variable    ${token}    ${Token}
    
Assert Result 0
    [Arguments]    ${response}
    ${result_code}    Set Variable    ${response.json()}[result]
    Should Be Equal As Integers    ${result_code}    0

Apply Trigger Single Mode
    [Documentation]    單一觸發的自動化排程，以滿足建立多個不同通知頻率的排程
    [Arguments]    ${name}    ${frequency}    ${device}    ${node}    ${time_start}    ${time_end}
    Fill Text    id=automated_name_name    ${name}
    Select Options By    id=automated_trigger_condition_condition_type    value    3
    Click With Options    label[for="automated_trigger_condition_type_2"]    delay=100ms
    Select Options By    id=automated_trigger_condition_device    value    ${device}
    Select Options By    id=automated_trigger_condition_node    value    ${node}
    Select Options By    id=automated_trigger_condition_compare    value    0
    Fill Text    id=automated_trigger_condition_compare_val    0
    # 選擇通知頻率
    Click With Options    label[for="automated_trigger_condition_frequency_${frequency}"]    delay=200ms
    Scroll To Element    id=automated_automated_control_device
    Select Options By    id=automated_automated_control_device    value    Do_123
    Select Options By    id=automated_automated_control_node    value    Do_00
    Select Options By    id=automated_automated_control_di_node_value    value    0
    # 點擊啟用週期switch及展開icon
    Click With Options    id=schedule_switch    delay=200ms
    Click With Options    xpath=/html/body/div[21]/div[2]/div[12]/div[2]    delay=200ms
    Sleep    1s
    Get Attribute    id=wf_automated_control    class    ==    collapse show
    Click With Options    id=automated_schedule_schedule_0    delay=100ms
    Select Options By    id=automated_schedule_schedule_time_0_start    value    ${time_start}
    Select Options By    id=automated_schedule_schedule_time_0_end    value    ${time_end}
    Wait For Elements State    id=basicOffcanvas_submit    enabled
    Click With Options    id=basicOffcanvas_submit    delay=200ms
    
Apply Trigger Any And All Mode
    [Documentation]    單一觸發的自動化排程，以滿足建立多個不同通知頻率的排程
    [Arguments]    ${type}    ${name}    ${frequency}    ${device}    ${node}    ${time_start}    ${time_end}
    Fill Text    id=automated_name_name    ${name}
    Select Options By    id=automated_trigger_condition_condition_type    value    ${type}
    Click With Options    xpath=//input[@id='automated_trigger_condition_type_1_2']/parent::div[@class='radio']/span    delay=300ms
    Select Options By    id=automated_trigger_condition_device_1    value    ${device}
    Select Options By    id=automated_trigger_condition_node_1    value    ${node}
    Select Options By    id=automated_trigger_condition_compare_1    value    0
    Fill Text    id=automated_trigger_condition_compare_val_1    0
    # 選擇通知頻率
    Click With Options    label[for="automated_trigger_condition_frequency_${frequency}"]    delay=200ms
    Scroll To Element    id=automated_automated_control_device
    Select Options By    id=automated_automated_control_device    value    Do_123
    Select Options By    id=automated_automated_control_node    value    Do_04
    Select Options By    id=automated_automated_control_di_node_value    value    0
    # 點擊啟用週期switch及展開icon
    Click With Options    id=schedule_switch    delay=200ms
    Click With Options    xpath=/html/body/div[21]/div[2]/div[12]/div[2]    delay=200ms
    Sleep    1s
    Get Attribute    id=wf_automated_control    class    ==    collapse show
    Click With Options    id=automated_schedule_schedule_0    delay=100ms
    Select Options By    id=automated_schedule_schedule_time_0_start    value    ${time_start}
    Select Options By    id=automated_schedule_schedule_time_0_end    value    ${time_end}
    Wait For Elements State    id=basicOffcanvas_submit    enabled
    Click With Options    id=basicOffcanvas_submit    delay=200ms