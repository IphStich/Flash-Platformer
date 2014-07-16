package iphstich.platformer.test
{
	import iphstich.platformer.engine.entities.projectiles.Bullet;
	import iphstich.platformer.engine.weapons.Weapon;
	import iphstich.platformer.test.TestBullet;
	/**
	 * ...
	 * @author IphStich
	 */
	public class TestWeapon extends Weapon
	{
		override public function triggerPull () : void
		{
			var b:Bullet = new TestBullet();
			b.shoot(host.level, host.x, host.y + (host.hitBox.top + host.hitBox.bottom) / 2, host.facing * 500, 0);
		}
	}
}