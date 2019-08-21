package com.tian.bean;

/**
 * 时间日志bean - 用户前台活跃
 *
 * @author JARVIS
 * @version 1.0
 * 2019/8/21 12:56
 */
public class AppActive_foreground {
    private String push_id;//推送的消息的id，如果不是从推送消息打开，传空
    private String access;//1.push 2.icon 3.其他

    public String getPush_id() {
        return push_id;
    }

    public void setPush_id(String push_id) {
        this.push_id = push_id;
    }

    public String getAccess() {
        return access;
    }

    public void setAccess(String access) {
        this.access = access;
    }
}

