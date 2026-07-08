import {TestBed} from '@angular/core/testing';
import {AppVersionsTable} from './app-versions-table';
import {AppVersionsService} from '../app-versions.service';
import {AppVersion} from '../../das-admin-api';

const mockAppVersionsService = {
  edit: vi.fn(),
  add: vi.fn(),
  appVersionsResource: new Proxy({}, {get: () => vi.fn()}),
};

const appVersion: AppVersion = {
  id: 1,
  version: '1.0.0',
  minimalVersion: true,
  expiryDate: new Date('2026-12-31'),
};

function createComponent(): AppVersionsTable {
  TestBed.configureTestingModule({
    providers: [
      AppVersionsTable,
      {provide: AppVersionsService, useValue: mockAppVersionsService},
    ],
  });
  return TestBed.inject(AppVersionsTable);
}

describe('AppVersionsTable', () => {
  beforeEach(() => vi.clearAllMocks());

  describe('edit', () => {
    it('should call appVersionsService.edit with the app version', async () => {
      const comp = createComponent();
      await comp['edit'](appVersion);
      expect(mockAppVersionsService.edit).toHaveBeenCalledWith(appVersion);
    });
  });

  describe('add', () => {
    it('should call appVersionsService.add', async () => {
      const comp = createComponent();
      await comp['add']();
      expect(mockAppVersionsService.add).toHaveBeenCalled();
    });
  });
});
