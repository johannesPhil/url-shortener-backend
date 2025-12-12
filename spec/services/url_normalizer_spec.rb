require 'spec_helper'

RSpec.describe UrlNormalizer do
subject { FactoryBot.build(:normalized_url) }
    describe '.call' do
        context 'when the URL is invalid' do
            # raises invalid URL
            it "raises invalid for nil value" do
                expect { UrlNormalizer.call(nil) }.to raise_error(UrlNormalizer::InvalidUrl)
            end
            it "raises invalid for empty string" do
                expect { UrlNormalizer.call('') }.to raise_error(UrlNormalizer::InvalidUrl)
            end
            it "raises invalid for invalid URL" do
                expect { UrlNormalizer.call('h!ps://example..com') }.to raise_error(UrlNormalizer::InvalidUrl)
            end
        end

        context 'scheme handling' do
            # handles http
            # handles https
            it 'adds the scheme' do
            result = UrlNormalizer.call('example.com')
            expect(result[:scheme]).to eq('https')
            expect(result[:normalized]).to eq('https://example.com')
            end
        end

        context 'host handling' do
          # downcase hostname
          it 'downcases the hostname' do
            result = UrlNormalizer.call('Example.com')
            expect(result[:host]).to_eq('example.com')
            expect(result[:normalized]).to eq('https://example.com')
          end
        end

        context 'trailing slash normalization' do
            # remove trailing slash at root
            # keep slash in paths
            it 'removes trailing slash at root' do
                result = UrlNormalizer.call('https://example.com/')
                expect(result[:path]).to_eq('')
                expect(result[:normalized]).to eq('https://example.com')
            end
            it 'keeps slash in paths' do
                result = UrlNormalizer.call('example.com/path/')
                expect(result[:path]).to_eq('/path/')
                expect(result[:normalized]).to eq('https://example.com/path/')
            end
        end

        context 'query parameter normalization ' do
            # alphabetize query parameter keys
            # keep original case
            # preserve duplicate keys
            it 'alphabetizes query parameter keys' do
                result = UrlNormalizer.call('example.com?b=2&a=1&c=3')
                expect(result[:query]).to eq([ [ 'a', '1' ], [ 'b', '2' ], [ 'c', '3' ] ])
                expect(result[:normalized]).to eq('https://example.com?b=2&a=1&c=3')
            end
            it 'keeps original case' do
                result = UrlNormalizer.call('example.com?B=2&a=1&C=3')
                expect(result[:query]).to eq([ [ 'a', '1' ], [ 'B', '2' ], [ 'C', '3' ] ])
                expect(result[:normalized]).to eq('https://example.com?a=1&B=2&C=3')
            end
            it 'preserves duplicate keys' do
                result = UrlNormalizer.call('example.com?a=1&a=2&c=3')
                expect(result[:query]).to eq([ [ 'a', '1' ], [ 'a', '2' ], [ 'c', '3' ] ])
                expect(result[:normalized]).to eq('https://example.com?a=1&a=2&c=3')
            end
        end
    end
end
