package com.tian.bean;

/**
 * 事件日志bean - 用户后台活跃
 *
 * @author JARVIS
 * @version 1.0
 * 2019/8/21 12:56
 */
public class AppActive_background {
    private String active_source;//1=upgrade,2=download(下载),3=plugin_upgrade

    public String getActive_source() {
        return active_source;
    }

    public void setActive_source(String active_source) {
        this.active_source = active_source;
    }
}

