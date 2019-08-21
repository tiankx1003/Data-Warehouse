package com.tian.bean;

/**
 * 错误日志bean
 *
 * @author JARVIS
 * @version 1.0
 * 2019/8/21 12:48
 */
public class AppErrorLog {

    private String errorBrief;    //错误摘要
    private String errorDetail;   //错误详情

    public String getErrorBrief() {
        return errorBrief;
    }

    public void setErrorBrief(String errorBrief) {
        this.errorBrief = errorBrief;
    }

    public String getErrorDetail() {
        return errorDetail;
    }

    public void setErrorDetail(String errorDetail) {
        this.errorDetail = errorDetail;
    }
}

