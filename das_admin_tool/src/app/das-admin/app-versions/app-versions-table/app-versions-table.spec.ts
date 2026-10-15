import { TestBed } from '@angular/core/testing';
import { AppVersion } from '~app/das-admin/das-admin.api';
import { AppVersionService } from '../app-version.service';
import { AppVersionsTable } from './app-versions-table';

const mockAppVersionService = {
  edit: vi.fn(),
  add: vi.fn(),
  appVersionsResource: new Proxy({}, { get: () => vi.fn() }),
};

const appVersion: AppVersion = {
  id: 1,
  version: '1.0.0',
  minimalVersion: true,
  expiryDate: '2026-12-31',
};

function createComponent(): AppVersionsTable {
  TestBed.configureTestingModule({
    providers: [AppVersionsTable, { provide: AppVersionService, useValue: mockAppVersionService }],
  });
  return TestBed.inject(AppVersionsTable);
}

describe('AppVersionsTable', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('edit', () => {
    it('should call appVersionService.edit with the app version', async () => {
      const comp = createComponent();
      await comp['edit'](appVersion);
      expect(mockAppVersionService.edit).toHaveBeenCalledWith(appVersion);
    });
  });

  describe('add', () => {
    it('should call appVersionService.add', async () => {
      const comp = createComponent();
      await comp['add']();
      expect(mockAppVersionService.add).toHaveBeenCalled();
    });
  });
});
