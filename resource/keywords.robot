*** Settings ***
Resource    ../init.robot
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
