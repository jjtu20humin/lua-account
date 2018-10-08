<div id="div_passwd">
	<form action="" class="am-form" data-am-validator>
		<fieldset>
			<legend>密码验证</legend>
			<div class="am-form-group">
				<label for="doc-vld-name-2">用户名：</label>
				<input type="text" id="doc-vld-name-2" minlength="3"
							 placeholder="输入用户名（至少 3 个字符）" required/>
			</div>

			<div class="am-form-group">
				<label for="doc-vld-pwd-1">密码：</label>
				<input type="password" id="doc-vld-pwd-1" placeholder="6 位数字的银行卡密码" pattern="^\d{6}$" required/>
			</div>

			<div class="am-form-group">
				<label for="doc-vld-pwd-2">确认密码：</label>
				<input type="password" id="doc-vld-pwd-2" placeholder="请与上面输入的值一致" data-equal-to="#doc-vld-pwd-1" required/>
			</div>

			<button class="am-btn am-btn-secondary" type="button">提交<tton>
		</fieldset>
	</form>
</div>