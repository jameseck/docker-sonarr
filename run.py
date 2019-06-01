#!/usr/bin/env python2

from xml.etree import ElementTree
from xml.dom import minidom
import os

if 'CONFIG_FILE' in os.environ:
    config_file = os.environ['CONFIG_FILE']
else:
    config_file = '/config/config.xml'

def xmltodict(element):
    if not isinstance(element, ElementTree.Element):
        raise ValueError('must pass xml.etree.ElementTree.Element object')

    def xmltodict_handler(parent_element):
        result = dict()
        for element in parent_element:
            if len(element):
                obj = xmltodict_handler(element)
            else:
                obj = element.text

            if result.get(element.tag):
                if hasattr(result[element.tag], 'append'):
                    result[element.tag].append(obj)
                else:
                    result[element.tag] = [result[element.tag], obj]
            else:
                result[element.tag] = obj
        return result

    return {element.tag: xmltodict_handler(element)}


def dicttoxml(element):
    if not isinstance(element, dict):
        raise ValueError('must pass dict type')
    if len(element) != 1:
        raise ValueError('dict must have exactly one root key')

    def dicttoxml_handler(result, key, value):
        if isinstance(value, list):
            for e in value:
                dicttoxml_handler(result, key, e)
        elif isinstance(value, basestring):
            elem = ElementTree.Element(key)
            elem.text = value
            result.append(elem)
        elif isinstance(value, int) or isinstance(value, float):
            elem = ElementTree.Element(key)
            elem.text = str(value)
            result.append(elem)
        elif value is None:
            result.append(ElementTree.Element(key))
        else:
            res = ElementTree.Element(key)
            for k, v in value.items():
                dicttoxml_handler(res, k, v)
            result.append(res)

    result = ElementTree.Element(element.keys()[0])
    for key, value in element[element.keys()[0]].items():
        dicttoxml_handler(result, key, value)
    return result

def xmlfiletodict(filename):
    return xmltodict(ElementTree.parse(filename).getroot())

def dicttoxmlfile(element, filename):
    #ElementTree.ElementTree(dicttoxml(element)).write(filename)
    with open(filename, 'w') as f:
        f.write(minidom.parseString(ElementTree.tostring(dicttoxml(element))).toprettyxml(indent='  '))

def xmlstringtodict(xmlstring):
    return xmltodict(ElementTree.fromstring(xmlstring).getroot())

def dicttoxmlstring(element):
    return ElementTree.tostring(dicttoxml(element))

default_config_dict = {
 'Config': {
    'ApiKey': None,
    'AuthenticationMethod': 'None',
    'BindAddress': '*',
    'Branch': 'master',
    'EnableSsl': 'False',
    'LaunchBrowser': 'False',
    'LogLevel': 'Info',
    'Port': '8989',
    'SslCertHash': None,
    'SslPort': '9898',
    'UpdateMechanism': 'BuiltIn',
    'UrlBase': None
  }
}

if os.path.exists(config_file):
    try:
        config_dict = xmlfiletodict(config_file)
    except ElementTree.ParseError:
        config_dict = {}
else:
    config_dict = {}

if not 'Config' in config_dict:
  config_dict['Config'] = {}

# Merge the defaults with the loaded config (if there is any)
for k in default_config_dict['Config']:
    if not k in config_dict['Config']:
        config_dict['Config'][k] = default_config_dict['Config'][k]

# Handle environment variables
# For each key in the dict, look for env variable with uppercased name and set it in config dict
for k in config_dict['Config']:
    if k.upper() in os.environ:
        print "Found %s in env" % k.upper()
        config_dict['Config'][k] = os.environ[k.upper()]

dicttoxmlfile(config_dict, config_file)

os.execv("/usr/bin/mono", ("/usr/bin/mono", "/NzbDrone/NzbDrone.exe", "-nobrowser", "-data=/config"))
