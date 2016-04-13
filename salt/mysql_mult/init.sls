#!py
#coding: utf-8
import subprocess
 
class MY_ERROR(Exception):
  def __init__(self,value):
    self.value=value
  def __str__(self):
    return self.value
 
def mysql():
  """
  1,检查是minion中pillar是否有mysql参数,以及参数是否合法
  如果参数没有问题，则返回对应版本的include配置
  pillar e.q.
  mysql:
    ports:
      - 3306
      - 3307
    version: '5.6.19'
  """
#  mysql_sls_path='mysql.'
  #必要的参数
  required_keys=['mysql_version','ports','mysql_user','mysql_password','mysql_dir','mysqldata_dir']
  if __pillar__.has_key('mysql'):
    mysql_d=__pillar__['mysql']
    #不存在必要的键值对则返回None
    for key in required_keys:
      if not mysql_d.has_key(key) or str(mysql_d[key]).strip()=="":
        raise MY_ERROR('key error! key: %s'%(str(key)))
    #判断port是否合法
    for port in mysql_d['ports']:
      if not port or not 1024<int(port)<65535:
        raise MY_ERROR('mysql ports value error: %s'%(str(mysql_d['ports'])))
    #组合配置参数
#    cfg=mysql_sls_path+str(mysql_d['version'][0])
    cfg='mysql.sls' 
    return cfg
  return None
 
def run():
  config={}
  config['include']=[]
  #mysql
  mysql_cfg=mysql()
  if mysql_cfg:
    config['include'].append(mysql_cfg)
  if config['include']==[]:
    return {}
  return config
