package com.geekive.geekiveArchiveAdmin.mapper.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.geekive.geekiveArchiveAdmin.common.Util;
import com.geekive.geekiveArchiveAdmin.geekiveCustom.GeekiveMap;
import com.geekive.geekiveArchiveAdmin.mapper.CommonMapper;
import com.geekive.geekiveArchiveAdmin.mapper.LoginMapper;
import com.geekive.geekiveArchiveAdmin.vo.CommonVO;

@Service
public class CommonService implements CommonMapper{
	
	@Autowired
	CommonMapper commonMapper;

	@Override
	public List<Map<String, Object>> selectAllMenu(Object object) {
		return commonMapper.selectAllMenu(object);
	}

	@Override
	public String selectSelectedMenuTitle(String path, boolean korean) {
		return commonMapper.selectSelectedMenuTitle(path, korean);
	}

	@Override
	public String selectProfileImageUrlPath(GeekiveMap gMap) {
		return commonMapper.selectProfileImageUrlPath(gMap);
	}
}
