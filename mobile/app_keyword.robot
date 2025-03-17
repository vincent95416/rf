*** Settings ***
Library    AppiumLibrary
*** Keywords ***
Initialize Window Size
    ${Width}=    Get Window Width
    ${Height}=   Get Window Height
    Set Global Variable    ${Width}
    Set Global Variable    ${Height}

Click And Input
    [Arguments]    ${locator}    ${expected_text}
    Click Element    ${locator}
    Input Text    ${locator}    ${expected_text}


Check All Elements Have Attribute
    [Arguments]    ${locator}    ${verify_attr}
    ${elements}    Get Webelements    ${locator}
    ${list_count}    Get Length    ${elements}
    Run Keyword If    ${list_count} == 0    Fail
    FOR    ${element}    IN    @{elements}
        Element Attribute Should Match    ${locator}    ${verify_attr}    true
    END

Verify Element Enabled And Click
    [Arguments]    ${locator}
    Element Should Be Enabled    ${locator}
    Click Element    ${locator}

Get Time Range From Element
    ${time_range_element}=    Get Webelement    xpath=//*[contains(@content-desc, "下載")]
    ${time_range_text}=    Get Element Attribute    ${time_range_element}    content-desc
    # 使用正則表達式提取【】之間的文字
    ${time_range}=    Get Regexp Matches    ${time_range_text}    【(.+?)】    1
    ${time_range}=    Set Variable    ${time_range}[0]
    Set Test Variable    ${time_range}

Check Video File Exists
    [Arguments]    ${filename}
    Run Process    adb    shell    ls    /storage/emulated/0/Download/${filename}
    #Should Be Equal As Integers    ${ls_result.rc}    1    找不到下載的影片檔案: ${filename}
    Run Process    adb    shell    stat    -f    %s    /storage/emulated/0/Download/${filename}

Verify Download File
    ${name_formatted}=    Replace String    ${time_range}    :    _
    Log    原始時間範圍: ${time_range}    level=INFO
    Log    格式化後名稱: ${name_formatted}    level=INFO
    Set Test Variable    ${EXPECTED_FILENAME}    ${name_formatted}.mp4
    Wait Until Keyword Succeeds    15s    5s    Check Video File Exists    ${EXPECTED_FILENAME}

Swipe Down To Find Element
    [Arguments]    ${locator}    ${start_y}    ${end_y}
    ${visible}    Set Variable    ${FALSE}
    FOR    ${i}    IN RANGE    3
        ${visible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}
        Run Keyword If    ${visible}    Exit For Loop
        Swipe By Percent    50    ${start_y}    50    ${end_y}    1000
    END
    Run Keyword If    not ${visible}    Fail    Element not found after scrolling

From Element Get Version
    [Arguments]    ${locator}    ${attribute}
    ${version_element}    Get Webelement    ${locator}
    ${element_text}    Get Element Attribute    ${locator}    ${attribute}
    ${version_text}    Split String    ${element_text}    \n
    ${version_with_v}    Set Variable    ${version_text}[1]