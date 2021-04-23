// 填入你的配置，或者通过环境变量传入
const QYWX_KEY = '' || process.env.QYWX_KEY;
const QYWX_AM = '' || process.env.QYWX_AM;

const express = require('express');
const got = require('got');
const path = require('path');
const bodyParser = require('body-parser');
const app = express();
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

/**
 * 字符串工具函数
 * 从 'xxx=yyy' 中提取 'yyy'
 *
 * @param {*} key
 * @return {string} value
 */
const transformKey = (key) => {
  return key.substring(key.indexOf('=') + 1, key.indexOf(';'));
};

/**
 * 通过res获取cookie
 * 此cookie用来请求二维码
 *
 * @param {*} response
 * @return {*}
 */
const praseSetCookies = (response) => {
  const s_token = response.body.s_token;
  const guid = transformKey(response.headers['set-cookie'][0]);
  const lsid = transformKey(response.headers['set-cookie'][2]);
  const lstoken = transformKey(response.headers['set-cookie'][3]);
  const cookies = `guid=${guid}; lang=chs; lsid=${lsid}; lstoken=${lstoken};`;
  return {
    s_token,
    guid,
    lsid,
    lstoken,
    cookies,
  };
};

/**
 * 通过res解析headers获得cookie
 *
 * @param {*} response
 * @return {string} userCookie
 */
const getCookie = (response) => {
  // 注释的参数没用，如果二次修改请自行研究
  // const TrackerID = transformKey(response.headers['set-cookie'][0]);
  // const pt_token = transformKey(response.headers['set-cookie'][3]);
  // const pwdt_id = transformKey(response.headers['set-cookie'][4]);
  // const s_key = transformKey(response.headers['set-cookie'][5]);
  // const s_pin = transformKey(response.headers['set-cookie'][6]);

  const pt_key = transformKey(response.headers['set-cookie'][1]);
  const pt_pin = transformKey(response.headers['set-cookie'][2]);
  const userCookie = `pt_key=${pt_key};pt_pin=${pt_pin};`;
  console.log({
    msg: '登录成功',
    time: new Date().toISOString(),
    userCookie,
    pt_pin,
  });
  return userCookie;
};

/**
 * 初始化请求二维码的参数
 *
 */
async function step1() {
  const timeStamp = new Date().getTime();
  const loginUrl =
    'https://plogin.m.jd.com/cgi-bin/mm/new_login_entrance?lang=chs&appid=300' +
    `&returnurl=https://wq.jd.com/passport/LoginRedirect?state=${timeStamp}` +
    '&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport';

  const response = await got(loginUrl, {
    responseType: 'json',
    headers: {
      Connection: 'Keep-Alive',
      'Content-Type': 'application/x-www-form-urlencoded',
      Accept: 'application/json, text/plain, */*',
      'Accept-Language': 'zh-cn',
      Referer:
        'https://plogin.m.jd.com/login/login?appid=300' +
        `&returnurl=https://wq.jd.com/passport/LoginRedirect?state=${timeStamp}` +
        '&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport',
      'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
      Host: 'plogin.m.jd.com',
    },
  });

  return praseSetCookies(response);
}

/**
 * 获取二维码链接
 *
 * @param {*} cookiesObj
 * @return {*}
 */
async function step2(cookiesObj) {
  const { s_token, guid, lsid, lstoken, cookies } = cookiesObj;
  if (cookies == '') {
    throw new Error('获取失败');
  }
  const timeStamp = new Date().getTime();
  const getQRUrl =
    'https://plogin.m.jd.com/cgi-bin/m/tmauthreflogurl?s_token=' +
    `${s_token}&v=${timeStamp}&remember=true`;
  const response = await got.post(getQRUrl, {
    responseType: 'json',
    json: {
      lang: 'chs',
      appid: 300,
      returnurl:
        `https://wqlogin2.jd.com/passport/LoginRedirect?state=${timeStamp}` +
        '&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action',
      source: 'wq_passport',
    },
    headers: {
      Connection: 'Keep-Alive',
      'Content-Type': 'application/x-www-form-urlencoded; Charset=UTF-8',
      Accept: 'application/json, text/plain, */*',
      Cookie: cookies,
      Referer:
        'https://plogin.m.jd.com/login/login?appid=300' +
        `&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=${timeStamp}` +
        '&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport',
      'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
      Host: 'plogin.m.jd.com',
    },
  });
  const token = response.body.token;
  const okl_token = transformKey(response.headers['set-cookie'][0]);
  const qrCodeUrl = `https://plogin.m.jd.com/cgi-bin/m/tmauth?appid=300&client_type=m&token=${token}`;
  return { ...cookiesObj, qrCodeUrl, okl_token, token };
}

/**
 * 通过前端传回的参数获得cookie
 *
 * @param {*} user
 * @return {*}
 */
async function checkLogin(user) {
  const { s_token, guid, lsid, lstoken, cookies, okl_token, token } = user;
  const timeStamp = new Date().getTime();
  const getUserCookieUrl =
    `https://plogin.m.jd.com/cgi-bin/m/tmauthchecktoken?&token=${token}` +
    `&ou_state=0&okl_token=${okl_token}`;
  const response = await got.post(getUserCookieUrl, {
    responseType: 'json',
    form: {
      lang: 'chs',
      appid: 300,
      returnurl:
        'https://wqlogin2.jd.com/passport/LoginRedirect?state=1100399130787&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action',
      source: 'wq_passport',
    },
    headers: {
      Referer:
        'https://plogin.m.jd.com/login/login?appid=300' +
        `&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=${timeStamp}` +
        '&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport',
      Cookie: cookies,
      Connection: 'Keep-Alive',
      'Content-Type': 'application/x-www-form-urlencoded; Charset=UTF-8',
      Accept: 'application/json, text/plain, */*',
      'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
    },
  });
  return response;
}

/**
 * 发送消息推送
 *
 * @param {*} msg
 */
async function sendMsg(msg) {
  // 企业微信群机器人
  if (QYWX_KEY) {
    try {
      await got.post(
        `https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=${QYWX_KEY}`,
        {
          responseType: 'json',
          json: {
            msgtype: 'text',
            text: {
              content: `获取到cookie：\n\n${msg}`,
            },
          },
        }
      );
    } catch (err) {
      console.log({
        msg: '企业微信群机器人消息发送失败',
        err: error.response.body,
      });
    }
  }
  if (QYWX_AM) {
    try {
      const [corpid, corpsecret, userId, agentid] = QYWX_AM.split(',');
      const getToken = await got.post({
        url: `https://qyapi.weixin.qq.com/cgi-bin/gettoken`,
        json: {
          corpid,
          corpsecret,
        },
        headers: {
          'Content-Type': 'application/json',
        },
        timeout: 10000,
      });
      const accessToken = JSON.parse(getToken.body).access_token;
      const res = await got.post({
        url: `https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=${accessToken}`,
        json: {
          touser: userId,
          agentid,
          safe: '0',
          msgtype: 'text',
          text: {
            content: `获取到cookie：\n\n${msg}`,
          },
        },
        headers: {
          'Content-Type': 'application/json',
        },
        timeout: 10000,
      });
    } catch (err) {
      console.log({
        msg: '企业微信应用消息发送失败',
        err: error.response.body,
      });
    }
  }
}

/**
 * API 获取二维码链接
 */
app.get('/qrcode', function (request, response) {
  (async () => {
    try {
      const cookiesObj = await step1();
      const user = await step2(cookiesObj);
      response.send({ err: 0, qrcode: user.qrCodeUrl, user });
    } catch (err) {
      response.send({ err: 2, msg: '错误' });
    }
  })();
});

/**
 * API 获取返回的cookie信息
 */
app.post('/cookie', function (request, response) {
  const user = request.body.user;
  if (user && user.cookies != '') {
    (async () => {
      try {
        const cookie = await checkLogin(user);
        if (cookie.body.errcode == 0) {
          let ucookie = getCookie(cookie);
          await sendMsg(ucookie);
          response.send({ err: 0, cookie: ucookie });
        } else {
          response.send({ err: cookie.body.errcode, msg: cookie.body.message });
        }
      } catch (err) {
        response.send({ err: 1, msg: err });
      }
    })();
  } else {
    response.send({ err: 2, msg: '获取失败' });
  }
});

// 本地运行开启以下
const PORT = 5678;
app.listen(PORT, () => {
  console.log(`应用正在监听 ${PORT} 端口!`);
});

// 云函数运行开启以下
// module.exports = app;
