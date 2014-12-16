/*jslint node: true */
/*global describe, it, before */

var cheerio = require('cheerio'),
    expect  = require('chai').expect;

describe('misc/test-cheerio.js', function()
{
    it('parsing html', function()
    {
        var $ = cheerio.load('<h2 class="title">Hello world</h2>');

        $('h2.title').text('Hello there!');
        $('h2').addClass('welcome');
        
        expect($.html()).to.equal('<h2 class="title welcome">Hello there!</h2>');
        $('h2').after('<h2>another one</h2>');
        expect($.html()).to.equal('<h2 class="title welcome">Hello there!</h2><h2>another one</h2>');
        
        expect($('h2').length).to.be.equal(2);        
        expect($('h2').first().html()).to.be.equal('Hello there!');        
        expect($('h2').attr("class")).to.be.equal('title welcome');
        $('h2').removeClass('welcome');
        expect($('h2').attr("class")).to.be.equal('title');
    });
});
