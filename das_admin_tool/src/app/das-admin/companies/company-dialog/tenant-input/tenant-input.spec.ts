import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TenantInput } from './tenant-input';

describe('TenantInput', () => {
  let component: TenantInput;
  let fixture: ComponentFixture<TenantInput>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({ imports: [TenantInput] }).compileComponents();

    fixture = TestBed.createComponent(TenantInput);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
